/*
  # Fix User Tracking and Status
  
  1. Changes
    - Add tracking_enabled column to profiles
    - Update trigger to handle tracking state
    - Add function to toggle tracking state
*/

-- Add tracking column to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS tracking_enabled boolean DEFAULT false;

-- Update the location status trigger
CREATE OR REPLACE FUNCTION update_user_location_status()
RETURNS trigger AS $$
BEGIN
  UPDATE profiles
  SET 
    is_active = true,
    tracking_enabled = true,
    last_location_update = NEW.timestamp
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to toggle tracking
CREATE OR REPLACE FUNCTION toggle_tracking(user_id uuid, enabled boolean)
RETURNS void AS $$
BEGIN
  UPDATE profiles
  SET 
    tracking_enabled = enabled,
    is_active = CASE WHEN enabled THEN true ELSE false END
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;