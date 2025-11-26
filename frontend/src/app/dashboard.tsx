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
  const sensorData = useSensorData();
  const latest = sensorData[sensorData.length - 1];

  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-700 p-8">
      <h1 className="text-5xl font-extrabold text-white mb-8">Smart CityOps Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
        <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }} className="bg-white rounded-xl shadow-lg p-8 flex flex-col items-center">
          <span className="text-lg text-gray-500 mb-2">Current Pollution Value</span>
          <AnimatedNumber value={latest.value} />
          <span className="text-sm text-gray-400 mt-2">Sensor ID: pollution_008</span>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1 }} className="bg-white rounded-xl shadow-lg p-8">
          <span className="text-lg text-gray-500 mb-4">Pollution Trend (last 20 readings)</span>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={sensorData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="timestamp" tick={{ fill: '#888' }} />
              <YAxis tick={{ fill: '#888' }} />
              <Tooltip />
              <Line type="monotone" dataKey="value" stroke="#16a34a" strokeWidth={3} dot={{ r: 6 }} isAnimationActive={true} />
            </LineChart>
          </ResponsiveContainer>
        </motion.div>
      </div>
      <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1.2 }} className="bg-white rounded-xl shadow-lg p-8">
        <h2 className="text-2xl font-bold mb-4">More Smart Stats Coming Soon...</h2>
        <p className="text-gray-500">Add more sensor types, animated cards, and interactive features to make your dashboard even smarter and more attractive!</p>
      </motion.div>
    </main>
  );
}
