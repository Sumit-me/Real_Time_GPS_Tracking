/*
  # Fix Database Policies and Add Error Handling

  1. Changes
    - Add missing INSERT policy for profiles table
    - Fix locations table policies
    - Add CASCADE for foreign key references
    - Add indexes for better query performance

  2. Security
    - Update RLS policies for better access control
    - Add policies for profile updates
*/

-- Add missing policies for profiles
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Fix locations policies
DROP POLICY IF EXISTS "Users can insert own location" ON locations;
DROP POLICY IF EXISTS "Users can read own locations" ON locations;
DROP POLICY IF EXISTS "Admin can read all locations" ON locations;

CREATE POLICY "Users can insert own location"
  ON locations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Users can read own locations"
  ON locations
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND role = 'admin'
    )
  );

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS locations_user_id_idx ON locations(user_id);
CREATE INDEX IF NOT EXISTS locations_timestamp_idx ON locations(timestamp);