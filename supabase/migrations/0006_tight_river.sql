/*
  # Add Role Metadata Support
  
  1. Changes
    - Modify handle_new_user function to support role selection during registration
*/

-- Modify the handle_new_user function to use metadata
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (
    new.id,
    COALESCE(
      (new.raw_user_meta_data->>'role')::text,
      'user'
    )
  );
  RETURN new;
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Error creating user profile: %', SQLERRM;
    RETURN null;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;