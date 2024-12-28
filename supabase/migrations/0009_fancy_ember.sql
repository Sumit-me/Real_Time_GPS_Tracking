/*
  # Fix Database Relationships
  
  1. Changes
    - Add foreign key relationship between profiles and auth.users
    - Update queries to use correct joins
    - Fix RLS policies
*/

-- Add foreign key relationship to auth.users
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS profiles_id_fkey,
ADD CONSTRAINT profiles_id_fkey 
  FOREIGN KEY (id) 
  REFERENCES auth.users(id) 
  ON DELETE CASCADE;

-- Update profiles view to include user email
CREATE OR REPLACE VIEW user_profiles AS
SELECT 
  p.id,
  u.email,
  p.role,
  p.is_active,
  p.last_location_update
FROM profiles p
JOIN auth.users u ON u.id = p.id;