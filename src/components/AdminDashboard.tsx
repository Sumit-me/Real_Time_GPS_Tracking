import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { supabase } from '../lib/supabase';
import { Navigation } from './Navigation';
import { UserList } from './admin/UserList';
import { UserLocationMap } from './admin/UserLocationMap';
import toast from 'react-hot-toast';
import 'leaflet/dist/leaflet.css';

export function AdminDashboard() {
  return (
    <div className="min-h-screen bg-gray-100">
      <Navigation />
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Admin Dashboard</h1>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <UserList />
          <UserLocationMap />
        </div>
      </div>
    </div>
  );
}