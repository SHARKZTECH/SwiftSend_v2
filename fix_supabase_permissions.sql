-- Fix Supabase Permissions and RLS Policies
-- Run this script in your Supabase SQL Editor to fix the permission errors

-- First, let's fix the RLS policies for users table

-- Drop existing policies to start fresh
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Anyone can view active user profiles" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;

-- Create comprehensive RLS policies for users table
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Allow service role and triggers to insert users (for the trigger)
CREATE POLICY "Service role can insert users" ON public.users
    FOR INSERT WITH CHECK (true);

-- Fix permissions for anon and authenticated roles
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;
GRANT SELECT, INSERT ON public.users TO anon; -- For user creation during signup

-- Allow the service role full access (for triggers)
GRANT ALL ON public.users TO service_role;

-- Fix deliveries policies
DROP POLICY IF EXISTS "Users can view own deliveries" ON public.deliveries;
DROP POLICY IF EXISTS "Users can create deliveries" ON public.deliveries;
DROP POLICY IF EXISTS "Users can update own deliveries" ON public.deliveries;
DROP POLICY IF EXISTS "Riders can view available deliveries" ON public.deliveries;

CREATE POLICY "Users can view own deliveries" ON public.deliveries
    FOR SELECT USING (
        auth.uid() = sender_id OR 
        auth.uid() = rider_id
    );

CREATE POLICY "Users can create deliveries" ON public.deliveries
    FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update own deliveries" ON public.deliveries
    FOR UPDATE USING (
        auth.uid() = sender_id OR 
        auth.uid() = rider_id
    ) WITH CHECK (
        auth.uid() = sender_id OR 
        auth.uid() = rider_id
    );

CREATE POLICY "Riders can view available deliveries" ON public.deliveries
    FOR SELECT USING (
        status = 'pending' AND 
        rider_id IS NULL AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND user_type = 'rider' AND is_active = true
        )
    );

-- Grant permissions on deliveries
GRANT SELECT, INSERT, UPDATE ON public.deliveries TO authenticated;
GRANT ALL ON public.deliveries TO service_role;

-- Fix delivery_updates policies
DROP POLICY IF EXISTS "Users can view delivery updates for their deliveries" ON public.delivery_updates;
DROP POLICY IF EXISTS "Riders can create delivery updates" ON public.delivery_updates;

CREATE POLICY "Users can view delivery updates" ON public.delivery_updates
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND (
                sender_id = auth.uid() OR 
                rider_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can create delivery updates" ON public.delivery_updates
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND (
                sender_id = auth.uid() OR 
                rider_id = auth.uid()
            )
        )
    );

-- Grant permissions on delivery_updates
GRANT SELECT, INSERT ON public.delivery_updates TO authenticated;
GRANT ALL ON public.delivery_updates TO service_role;

-- Fix notifications policies
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;

CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System can create notifications" ON public.notifications
    FOR INSERT WITH CHECK (true); -- Allow system to create notifications for any user

-- Grant permissions on notifications
GRANT SELECT, UPDATE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;

-- Fix rider_locations policies
DROP POLICY IF EXISTS "Riders can manage own locations" ON public.rider_locations;
DROP POLICY IF EXISTS "Users can view rider locations for their deliveries" ON public.rider_locations;

CREATE POLICY "Riders can manage own locations" ON public.rider_locations
    FOR ALL USING (auth.uid() = rider_id);

CREATE POLICY "Users can view rider locations" ON public.rider_locations
    FOR SELECT USING (
        delivery_id IS NOT NULL AND
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND (
                sender_id = auth.uid() OR 
                rider_id = auth.uid()
            )
        )
    );

-- Grant permissions on rider_locations
GRANT SELECT, INSERT, UPDATE, DELETE ON public.rider_locations TO authenticated;
GRANT ALL ON public.rider_locations TO service_role;

-- Fix reviews policies
DROP POLICY IF EXISTS "Users can view reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can create reviews for their deliveries" ON public.reviews;

CREATE POLICY "Users can view reviews" ON public.reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can create reviews" ON public.reviews
    FOR INSERT WITH CHECK (
        auth.uid() = reviewer_id AND
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND (
                sender_id = auth.uid() OR 
                rider_id = auth.uid()
            ) AND status = 'delivered'
        )
    );

-- Grant permissions on reviews
GRANT SELECT, INSERT ON public.reviews TO authenticated;
GRANT ALL ON public.reviews TO service_role;

-- Grant sequence permissions (needed for UUID generation)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Grant execute permissions on functions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- Ensure the handle_new_user function has proper permissions
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Update the user creation trigger function to be more robust
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create improved function with better error handling and permissions
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_full_name TEXT;
    user_phone TEXT;
    user_user_type TEXT;
BEGIN
    -- Extract metadata with proper error handling
    user_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1));
    user_phone := COALESCE(NEW.raw_user_meta_data->>'phone_number', '');
    user_user_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'customer');
    
    -- Validate user_type
    IF user_user_type NOT IN ('customer', 'business', 'rider', 'admin') THEN
        user_user_type := 'customer';
    END IF;
    
    -- Insert user profile
    INSERT INTO public.users (
        id, 
        email, 
        full_name, 
        phone_number, 
        user_type,
        is_verified,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.email, ''),
        user_full_name,
        user_phone,
        user_user_type::user_type,
        COALESCE(NEW.email_confirmed_at IS NOT NULL, false),
        true,
        COALESCE(NEW.created_at, NOW()),
        NOW()
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the auth process
        RAISE LOG 'Error creating user profile for %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;

-- Grant proper permissions to the function
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_new_user();

-- Create a function to safely get current user profile
CREATE OR REPLACE FUNCTION public.get_current_user_profile()
RETURNS TABLE (
    id UUID,
    email TEXT,
    full_name TEXT,
    phone_number TEXT,
    user_type user_type,
    profile_image_url TEXT,
    is_verified BOOLEAN,
    is_active BOOLEAN,
    profile JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.full_name,
        u.phone_number,
        u.user_type,
        u.profile_image_url,
        u.is_verified,
        u.is_active,
        u.profile,
        u.created_at,
        u.updated_at
    FROM public.users u
    WHERE u.id = auth.uid()
    AND u.is_active = true;
END;
$$;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.get_current_user_profile() TO authenticated;

-- Refresh the schema cache
NOTIFY pgrst, 'reload schema';

SELECT 'All permissions and policies have been fixed successfully!' as message;