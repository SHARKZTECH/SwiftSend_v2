-- SwiftSend Kenya Database Schema for Supabase
-- Run this script in your Supabase SQL editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types/enums
CREATE TYPE user_type AS ENUM ('customer', 'business', 'rider', 'admin');
CREATE TYPE delivery_status AS ENUM ('pending', 'accepted', 'picked_up', 'in_transit', 'delivered', 'cancelled', 'failed');
CREATE TYPE package_size AS ENUM ('small', 'medium', 'large', 'extra_large');
CREATE TYPE payment_method AS ENUM ('mpesa', 'airtel_money', 'card', 'cash');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    user_type user_type NOT NULL DEFAULT 'customer',
    profile_image_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    profile JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Create index on user_type for faster queries
CREATE INDEX users_user_type_idx ON public.users(user_type);
CREATE INDEX users_active_idx ON public.users(is_active);

-- Deliveries table
CREATE TABLE public.deliveries (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rider_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    receiver_name TEXT NOT NULL,
    receiver_phone TEXT NOT NULL,
    pickup_address TEXT NOT NULL,
    pickup_location JSONB NOT NULL, -- {latitude, longitude, address}
    dropoff_address TEXT NOT NULL,
    dropoff_location JSONB NOT NULL, -- {latitude, longitude, address}
    package_info JSONB NOT NULL, -- {size, description, is_fragile, requires_signature, weight, category}
    estimated_price DECIMAL(10,2) NOT NULL,
    final_price DECIMAL(10,2),
    status delivery_status DEFAULT 'pending' NOT NULL,
    special_instructions TEXT,
    payment_info JSONB, -- {transaction_id, method, status, amount, paid_at, phone_number}
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    accepted_at TIMESTAMP WITH TIME ZONE,
    picked_up_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Indexes for deliveries table
CREATE INDEX deliveries_sender_idx ON public.deliveries(sender_id);
CREATE INDEX deliveries_rider_idx ON public.deliveries(rider_id);
CREATE INDEX deliveries_status_idx ON public.deliveries(status);
CREATE INDEX deliveries_created_at_idx ON public.deliveries(created_at DESC);
CREATE INDEX deliveries_available_idx ON public.deliveries(status, rider_id) WHERE status = 'pending' AND rider_id IS NULL;

-- Delivery updates/tracking table
CREATE TABLE public.delivery_updates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    delivery_id UUID NOT NULL REFERENCES public.deliveries(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    message TEXT NOT NULL,
    location JSONB, -- {latitude, longitude, address}
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL
);

-- Index for delivery updates
CREATE INDEX delivery_updates_delivery_idx ON public.delivery_updates(delivery_id);
CREATE INDEX delivery_updates_timestamp_idx ON public.delivery_updates(timestamp DESC);

-- Notifications table
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- 'delivery_update', 'payment', 'promotion', 'system', 'rider'
    data JSONB, -- Additional notification data
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for notifications
CREATE INDEX notifications_user_idx ON public.notifications(user_id);
CREATE INDEX notifications_unread_idx ON public.notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX notifications_created_at_idx ON public.notifications(created_at DESC);

-- Rider locations table (for real-time tracking)
CREATE TABLE public.rider_locations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    rider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    delivery_id UUID REFERENCES public.deliveries(id) ON DELETE SET NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address TEXT,
    accuracy DECIMAL(10, 2), -- GPS accuracy in meters
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for rider locations
CREATE INDEX rider_locations_rider_idx ON public.rider_locations(rider_id);
CREATE INDEX rider_locations_delivery_idx ON public.rider_locations(delivery_id);
CREATE INDEX rider_locations_timestamp_idx ON public.rider_locations(timestamp DESC);

-- Ratings and reviews table
CREATE TABLE public.reviews (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    delivery_id UUID NOT NULL REFERENCES public.deliveries(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for reviews
CREATE INDEX reviews_delivery_idx ON public.reviews(delivery_id);
CREATE INDEX reviews_reviewee_idx ON public.reviews(reviewee_id);
CREATE UNIQUE INDEX reviews_unique_per_delivery ON public.reviews(delivery_id, reviewer_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON public.deliveries
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Function to automatically create user profile when auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, phone_number, user_type)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        COALESCE(NEW.raw_user_meta_data->>'phone_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'user_type', 'customer')::user_type
    );
    RETURN NEW;
END;
$$ language plpgsql security definer;

-- Trigger for auto-creating user profiles
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Anyone can view active user profiles" ON public.users
    FOR SELECT USING (is_active = true);

-- Deliveries policies
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
    );

CREATE POLICY "Riders can view available deliveries" ON public.deliveries
    FOR SELECT USING (
        status = 'pending' AND 
        rider_id IS NULL AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND user_type = 'rider'
        )
    );

-- Delivery updates policies
CREATE POLICY "Users can view delivery updates for their deliveries" ON public.delivery_updates
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND (
                sender_id = auth.uid() OR 
                rider_id = auth.uid()
            )
        )
    );

CREATE POLICY "Riders can create delivery updates" ON public.delivery_updates
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND 
            rider_id = auth.uid()
        )
    );

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Rider locations policies
CREATE POLICY "Riders can manage own locations" ON public.rider_locations
    FOR ALL USING (auth.uid() = rider_id);

CREATE POLICY "Users can view rider locations for their deliveries" ON public.rider_locations
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

-- Reviews policies
CREATE POLICY "Users can view reviews" ON public.reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can create reviews for their deliveries" ON public.reviews
    FOR INSERT WITH CHECK (
        auth.uid() = reviewer_id AND
        EXISTS (
            SELECT 1 FROM public.deliveries 
            WHERE id = delivery_id AND (
                sender_id = auth.uid() OR 
                rider_id = auth.uid()
            )
        )
    );

-- Functions for common operations

-- Get available deliveries for riders
CREATE OR REPLACE FUNCTION get_available_deliveries()
RETURNS TABLE (
    delivery_id UUID,
    pickup_address TEXT,
    dropoff_address TEXT,
    estimated_price DECIMAL,
    package_size TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.pickup_address,
        d.dropoff_address,
        d.estimated_price,
        (d.package_info->>'size')::TEXT,
        d.created_at
    FROM public.deliveries d
    WHERE d.status = 'pending' 
    AND d.rider_id IS NULL
    ORDER BY d.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Accept delivery function
CREATE OR REPLACE FUNCTION accept_delivery(delivery_uuid UUID, rider_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    delivery_exists BOOLEAN;
BEGIN
    -- Check if delivery is available
    SELECT EXISTS(
        SELECT 1 FROM public.deliveries 
        WHERE id = delivery_uuid 
        AND status = 'pending' 
        AND rider_id IS NULL
    ) INTO delivery_exists;
    
    IF NOT delivery_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Update delivery
    UPDATE public.deliveries 
    SET 
        rider_id = rider_uuid,
        status = 'accepted',
        accepted_at = NOW()
    WHERE id = delivery_uuid;
    
    -- Add delivery update
    INSERT INTO public.delivery_updates (delivery_id, status, message)
    VALUES (delivery_uuid, 'accepted', 'Delivery accepted by rider');
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update delivery status function
CREATE OR REPLACE FUNCTION update_delivery_status(
    delivery_uuid UUID, 
    new_status delivery_status,
    update_message TEXT DEFAULT NULL,
    rider_location JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Update delivery status
    UPDATE public.deliveries 
    SET 
        status = new_status,
        picked_up_at = CASE WHEN new_status = 'picked_up' THEN NOW() ELSE picked_up_at END,
        delivered_at = CASE WHEN new_status = 'delivered' THEN NOW() ELSE delivered_at END
    WHERE id = delivery_uuid;
    
    -- Add delivery update
    INSERT INTO public.delivery_updates (delivery_id, status, message, location)
    VALUES (
        delivery_uuid, 
        new_status::TEXT, 
        COALESCE(update_message, 'Status updated to ' || new_status::TEXT),
        rider_location
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create notification function
CREATE OR REPLACE FUNCTION create_notification(
    target_user_id UUID,
    notification_title TEXT,
    notification_message TEXT,
    notification_type TEXT,
    notification_data JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO public.notifications (user_id, title, message, type, data)
    VALUES (target_user_id, notification_title, notification_message, notification_type, notification_data)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Enable realtime for tables
ALTER publication supabase_realtime ADD TABLE public.deliveries;
ALTER publication supabase_realtime ADD TABLE public.delivery_updates;
ALTER publication supabase_realtime ADD TABLE public.rider_locations;
ALTER publication supabase_realtime ADD TABLE public.notifications;

-- Insert sample data (optional)
-- Uncomment if you want sample data

/*
-- Sample users (these will be created automatically when users sign up)
-- Sample deliveries
INSERT INTO public.deliveries (
    sender_id, 
    receiver_name, 
    receiver_phone,
    pickup_address,
    pickup_location,
    dropoff_address,
    dropoff_location,
    package_info,
    estimated_price
) VALUES (
    (SELECT id FROM auth.users LIMIT 1), -- Replace with actual user ID
    'John Doe',
    '+254700000001',
    'Westlands Shopping Mall',
    '{"latitude": -1.2676, "longitude": 36.8108, "address": "Westlands Shopping Mall"}',
    'Karen Shopping Centre',
    '{"latitude": -1.3197, "longitude": 36.6859, "address": "Karen Shopping Centre"}',
    '{"size": "medium", "description": "Electronics", "is_fragile": true, "requires_signature": false}',
    350.00
);
*/

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS deliveries_status_rider_idx 
    ON public.deliveries(status, rider_id) 
    WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS rider_locations_recent_idx 
    ON public.rider_locations(rider_id, timestamp DESC);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS deliveries_user_status_idx 
    ON public.deliveries(sender_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS deliveries_rider_status_idx 
    ON public.deliveries(rider_id, status, created_at DESC) 
    WHERE rider_id IS NOT NULL;

-- Comment
COMMENT ON TABLE public.users IS 'Extended user profiles linked to Supabase Auth';
COMMENT ON TABLE public.deliveries IS 'Main deliveries table with full delivery lifecycle';
COMMENT ON TABLE public.delivery_updates IS 'Tracking updates and status changes for deliveries';
COMMENT ON TABLE public.notifications IS 'User notifications for app events';
COMMENT ON TABLE public.rider_locations IS 'Real-time location tracking for riders';
COMMENT ON TABLE public.reviews IS 'Ratings and reviews for completed deliveries';

-- Final message
SELECT 'SwiftSend database schema created successfully!' as message;