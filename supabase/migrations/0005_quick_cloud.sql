/*
  # Create Initial Admin User
  
  1. Changes
    - Insert admin user directly into profiles table
    - Add function to check admin status
*/

-- Create a function to check if a user is an admin
CREATE OR REPLACE FUNCTION is_admin(user_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN user_email = 'admin@example.com';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Modify the handle_new_user function to use is_admin
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (
    new.id,
    CASE 
      WHEN is_admin(new.email)
      THEN 'admin'
      ELSE 'user'
    END
  );
  RETURN new;
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Error creating user profile: %', SQLERRM;
    RETURN null;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;