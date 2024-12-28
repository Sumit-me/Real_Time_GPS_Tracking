import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { supabase } from '../../lib/supabase';
import L from 'leaflet';

type UserLocation = {
  user_id: string;
  email: string;
  latitude: number;
  longitude: number;
  timestamp: string;
};

export function UserLocationMap() {
  const [locations, setLocations] = useState<UserLocation[]>([]);

  useEffect(() => {
    const fetchLocations = async () => {
      const { data, error } = await supabase
        .from('locations')
        .select(`
          user_id,
          latitude,
          longitude,
          timestamp,
          profiles!inner(
            users:user_profiles!inner(email)
          )
        `)
        .order('timestamp', { ascending: false });

      if (error) {
        console.error('Error fetching locations:', error);
        return;
      }

      const formattedLocations = data.map(loc => ({
        user_id: loc.user_id,
        email: loc.profiles.users.email,
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: loc.timestamp
      }));

      setLocations(formattedLocations);
    };

    fetchLocations();

    const subscription = supabase
      .channel('locations-changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'locations' }, fetchLocations)
      .subscribe();

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <div className="px-4 py-5 sm:px-6">
        <h3 className="text-lg leading-6 font-medium text-gray-900">User Locations</h3>
      </div>
      <div className="h-[600px]">
        <MapContainer
          center={[0, 0]}
          zoom={2}
          style={{ height: '100%', width: '100%' }}
        >
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          />
          {locations.map((location) => (
            <Marker
              key={`${location.user_id}-${location.timestamp}`}
              position={[location.latitude, location.longitude]}
            >
              <Popup>
                <div>
                  <p className="font-medium">{location.email}</p>
                  <p className="text-sm text-gray-500">
                    {new Date(location.timestamp).toLocaleString()}
                  </p>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
    </div>
  );
}