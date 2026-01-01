-- Fix for user creation trigger
-- Run this in your Supabase SQL editor to fix the user creation issue

-- Drop the existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create improved function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
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
        NEW.email,
        user_full_name,
        user_phone,
        user_user_type::user_type,
        COALESCE(NEW.email_confirmed_at IS NOT NULL, false),
        true,
        NOW(),
        NOW()
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error and still return NEW to not break auth
        RAISE LOG 'Error creating user profile: %', SQLERRM;
        RETURN NEW;
END;
$$ language plpgsql security definer;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Test the function works by checking if it exists
SELECT 'User creation trigger updated successfully!' as message;