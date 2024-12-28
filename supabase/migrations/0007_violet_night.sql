/*
  # Fix RLS Policies
  
  1. Changes
    - Drop existing problematic policies
    - Create new simplified RLS policies for locations table
    - Add proper authentication checks
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Enable location insert for users" ON locations;
DROP POLICY IF EXISTS "Enable location select for users" ON locations;

-- Create new simplified policies for locations
CREATE POLICY "Users can manage own locations"
  ON locations
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all locations"
  ON locations
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );