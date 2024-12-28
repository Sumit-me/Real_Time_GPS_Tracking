import { supabase } from './supabase';
import toast from 'react-hot-toast';

export async function saveLocation(latitude: number, longitude: number): Promise<boolean> {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      throw new Error('User not authenticated');
    }

    const { error } = await supabase.from('locations').insert([
      {
        user_id: user.id,
        latitude,
        longitude,
      }
    ]);

    if (error) {
      console.error('Error saving location:', error);
      throw error;
    }

    return true;
  } catch (error) {
    console.error('Failed to save location:', error);
    toast.error('Failed to save location. Please try again.');
    return false;
  }
}