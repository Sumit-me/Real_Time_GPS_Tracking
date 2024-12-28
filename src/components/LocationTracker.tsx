import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { supabase } from '../lib/supabase';
import { Navigation } from './Navigation';
import toast from 'react-hot-toast';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix Leaflet default icon issue
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

type Location = {
  latitude: number;
  longitude: number;
};

export function LocationTracker() {
  const [tracking, setTracking] = useState(false);
  const [location, setLocation] = useState<Location | null>(null);
  const [map, setMap] = useState<L.Map | null>(null);

  useEffect(() => {
    const checkTrackingStatus = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data } = await supabase
        .from('profiles')
        .select('tracking_enabled')
        .eq('id', user.id)
        .single();

      if (data?.tracking_enabled) {
        setTracking(true);
      }
    };

    checkTrackingStatus();
  }, []);

  useEffect(() => {
    let intervalId: number;

    const trackLocation = async () => {
      if (!tracking) return;

      try {
        const position = await new Promise<GeolocationPosition>((resolve, reject) => {
          navigator.geolocation.getCurrentPosition(resolve, reject, {
            enableHighAccuracy: true,
            timeout: 5000,
            maximumAge: 0
          });
        });

        const newLocation = {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
        };

        setLocation(newLocation);

        if (map && newLocation) {
          map.setView([newLocation.latitude, newLocation.longitude], map.getZoom());
        }

        const { data: { user } } = await supabase.auth.getUser();
        if (!user) throw new Error('Not authenticated');

        const { error } = await supabase.from('locations').insert([{
          user_id: user.id,
          ...newLocation,
        }]);

        if (error) throw error;
      } catch (error) {
        console.error('Failed to update location:', error);
        toast.error('Failed to update location');
        setTracking(false);
        await toggleTracking(false);
      }
    };

    if (tracking) {
      trackLocation();
      intervalId = window.setInterval(trackLocation, 4000);
    }

    return () => {
      if (intervalId) clearInterval(intervalId);
    };
  }, [tracking, map]);

  const toggleTracking = async (enabled: boolean) => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { error } = await supabase.rpc('toggle_tracking', {
        user_id: user.id,
        enabled: enabled
      });

      if (error) throw error;
      setTracking(enabled);
    } catch (error) {
      console.error('Error toggling tracking:', error);
      toast.error('Failed to update tracking status');
    }
  };

  return (
    <div>
      <Navigation />
      <div className="p-4">
        <div className="mb-4">
          <button
            onClick={() => toggleTracking(!tracking)}
            className={`px-4 py-2 rounded-md ${
              tracking
                ? 'bg-red-600 hover:bg-red-700'
                : 'bg-green-600 hover:bg-green-700'
            } text-white`}
          >
            {tracking ? 'Stop Tracking' : 'Start Tracking'}
          </button>
        </div>

        <div className="h-[600px] rounded-lg overflow-hidden shadow-md">
          {(!location && !tracking) ? (
            <div className="h-full flex items-center justify-center bg-gray-100">
              <p className="text-gray-600">Click "Start Tracking" to begin tracking your location</p>
            </div>
          ) : (
            <MapContainer
              center={location ? [location.latitude, location.longitude] : [0, 0]}
              zoom={13}
              style={{ height: '100%', width: '100%' }}
              ref={setMap}
            >
              <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              />
              {location && (
                <Marker position={[location.latitude, location.longitude]}>
                  <Popup>Your current location</Popup>
                </Marker>
              )}
            </MapContainer>
          )}
        </div>
      </div>
    </div>
  );
}