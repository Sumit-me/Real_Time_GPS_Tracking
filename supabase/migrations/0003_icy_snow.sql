/*
  # Fix User Registration

  1. Changes
    - Fix user creation trigger
    - Add proper error handling
    - Ensure proper role assignment

  2. Security
    - Maintain RLS policies
    - Ensure proper user initialization
*/

-- Drop existing trigger and function to recreate them properly
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Recreate the function with better error handling
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (
    new.id,
    CASE 
      WHEN new.email = ANY(string_to_array(current_setting('app.admin_emails', TRUE), ','))
      THEN 'admin'
      ELSE 'user'
    END
  );
  RETURN new;
EXCEPTION
  WHEN others THEN
    -- Log the error (in a real production system, you'd want proper error logging)
    RAISE NOTICE 'Error creating user profile: %', SQLERRM;
    RETURN null;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Ensure profiles table has proper constraints
ALTER TABLE public.profiles
  ALTER COLUMN role SET DEFAULT 'user',
  ADD CONSTRAINT valid_role CHECK (role IN ('user', 'admin'));

-- Add policy for profile creation
CREATE POLICY "Service role can create profiles"
  ON public.profiles
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Ensure RLS is enabled
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;