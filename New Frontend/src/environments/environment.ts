export const environment = {
  production: false,
  // Set to null or empty string to disable API calls and use local fallback only
  apiUrl: 'https://localhost:7216/api', // Your ASP.NET Core API URL (matches backend launchSettings.json)
  wsUrl: 'ws://localhost:7216', // WebSocket URL if needed
  // Set to true to enable API calls when backend is ready
  enableApi: true // Enable API - make sure backend is running on https://localhost:7216
};

