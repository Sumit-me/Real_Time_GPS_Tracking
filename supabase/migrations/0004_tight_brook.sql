/*
  # Fix Recursive Policies

  1. Changes
    - Remove recursive admin checks
    - Simplify policy structure
    - Add proper role-based policies
    - Fix infinite recursion in profile policies

  2. Security
    - Maintain proper access control
    - Prevent policy recursion
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Admin can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own location" ON locations;
DROP POLICY IF EXISTS "Users can read own locations" ON locations;

-- Create new non-recursive policies for profiles
CREATE POLICY "Enable read access for users"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (
    id = auth.uid() OR
    role = 'admin'
  );

CREATE POLICY "Enable update for users"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Create new policies for locations
CREATE POLICY "Enable location insert for users"
  ON locations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() OR
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Enable location select for users"
  ON locations
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
  );

-- Add missing indexes if they don't exist
CREATE INDEX IF NOT EXISTS locations_user_id_timestamp_idx 
  ON locations(user_id, timestamp DESC);

CREATE INDEX IF NOT EXISTS profiles_role_idx 
  ON profiles(role);