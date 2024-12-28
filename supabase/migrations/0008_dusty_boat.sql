/*
  # Add User Tracking Features
  
  1. Changes
    - Add is_active and last_location_update columns to profiles
    - Create function to update user status
    - Add trigger for location updates
*/

-- Add tracking columns to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS last_location_update timestamptz;

-- Create function to update user status and last location
CREATE OR REPLACE FUNCTION update_user_location_status()
RETURNS trigger AS $$
BEGIN
  UPDATE profiles
  SET 
    is_active = true,
    last_location_update = NEW.timestamp
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for location updates
CREATE TRIGGER on_location_update
  AFTER INSERT ON locations
  FOR EACH ROW
  EXECUTE FUNCTION update_user_location_status();