"use client";
import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

// Simulated sensor data generator
function useSensorData() {
  const [data, setData] = useState([
    { timestamp: '17:10:24', value: 345 },
    { timestamp: '17:11:24', value: 350 },
    { timestamp: '17:12:24', value: 355 },
  ]);
  useEffect(() => {
    const interval = setInterval(() => {
      const newValue = Math.floor(300 + Math.random() * 100);
      const newTimestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
      setData((prev) => [...prev.slice(-19), { timestamp: newTimestamp, value: newValue }]);
    }, 2000);
    return () => clearInterval(interval);
  }, []);
  return data;
}

// Animated number component
function AnimatedNumber({ value }: { value: number }) {
  const [display, setDisplay] = useState(value);
  useEffect(() => {
    const controls = setInterval(() => {
      setDisplay((prev) => {
        if (prev === value) return prev;
        const diff = value - prev;
        return prev + Math.sign(diff) * Math.ceil(Math.abs(diff) / 5);
      });
    }, 50);
    return () => clearInterval(controls);
  }, [value]);
  return (
    <motion.span animate={{ color: '#16a34a' }} transition={{ duration: 0.5 }} className="text-4xl font-bold">
      {display}
    </motion.span>
  );
}


export default function Dashboard() {
  // Simulate multiple sensor types
  const pollutionData = useSensorData();
  const trafficData = useSensorData();
  const weatherData = useSensorData();
  const energyData = useSensorData();

  const sensors = [
    {
      name: 'Pollution',
      color: 'bg-green-100',
      value: pollutionData[pollutionData.length - 1].value,
      id: 'pollution_008',
      icon: '🌫️',
      data: pollutionData,
    },
    {
      name: 'Traffic',
      color: 'bg-yellow-100',
      value: trafficData[trafficData.length - 1].value,
      id: 'traffic_002',
      icon: '🚗',
      data: trafficData,
    },
    {
      name: 'Weather',
      color: 'bg-blue-100',
      value: weatherData[weatherData.length - 1].value,
      id: 'weather_005',
      icon: '🌦️',
      data: weatherData,
    },
    {
      name: 'Energy',
      color: 'bg-purple-100',
      value: energyData[energyData.length - 1].value,
      id: 'energy_003',
      icon: '⚡',
      data: energyData,
    },
  ];

  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-700 p-8">
      <h1 className="text-5xl font-extrabold text-white mb-8 text-center">Smart CityOps Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-12">
        {sensors.map((sensor) => (
          <motion.div key={sensor.id} initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }} className={`rounded-xl shadow-lg p-8 flex flex-col items-center ${sensor.color}`} whileHover={{ scale: 1.05 }}>
            <span className="text-4xl mb-2">{sensor.icon}</span>
            <span className="text-lg text-gray-700 mb-2">Current {sensor.name} Value</span>
            <AnimatedNumber value={sensor.value} />
            <span className="text-sm text-gray-500 mt-2">Sensor ID: {sensor.id}</span>
          </motion.div>
        ))}
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
        {sensors.map((sensor) => (
          <motion.div key={sensor.id + '-chart'} initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1 }} className="bg-white rounded-xl shadow-lg p-8">
            <span className="text-lg text-gray-500 mb-4">{sensor.name} Trend (last 20 readings)</span>
            <ResponsiveContainer width="100%" height={200}>
              <LineChart data={sensor.data}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="timestamp" tick={{ fill: '#888' }} />
                <YAxis tick={{ fill: '#888' }} />
                <Tooltip />
                <Line type="monotone" dataKey="value" stroke="#16a34a" strokeWidth={3} dot={{ r: 6 }} isAnimationActive={true} />
              </LineChart>
            </ResponsiveContainer>
          </motion.div>
        ))}
      </div>
      <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1.2 }} className="bg-white rounded-xl shadow-lg p-8 text-center">
        <h2 className="text-2xl font-bold mb-4">Welcome to Your Smart City!</h2>
        <p className="text-gray-500 mb-2">Interact with animated cards, explore live sensor trends, and enjoy a beautiful dashboard experience.</p>
        <p className="text-gray-500">Add more features, connect to real APIs, and make your dashboard even smarter and happier!</p>
      </motion.div>
    </main>
  );
}
