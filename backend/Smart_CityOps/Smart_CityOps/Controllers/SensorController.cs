using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Smart_CityOps.Data;
using Smart_CityOps.Entities;

namespace Smart_CityOps.Controllers
{
    [Route("api/sensors")]
    [ApiController]
    public class SensorController : ControllerBase
    {
        private readonly SmartCityContext _context;

        public SensorController(SmartCityContext context)
        {
            _context = context;
        }

        [HttpGet("dashboard-stats")]
        [Authorize]
        public async Task<IActionResult> GetDashboardStats()
        {
            var now = DateTime.UtcNow;

            // PERFORMANCE FIX: 
            // 1. Sort by ID (Indexed) instead of Timestamp (Unindexed string).
            // 2. Take only the latest 1000 rows.
            var rawLatestData = await _context.SensorData
                .OrderByDescending(s => s.Id)
                .Take(1000)
                .ToListAsync();

            // 3. Filter for "Last Hour" insights in Memory (Fast)
            string oneHourAgo = now.AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ss");

            var recentData = rawLatestData
                .Where(s => string.Compare(s.Timestamp, oneHourAgo) >= 0)
                .ToList();

            // 4. Calculate Stats
            var pollutionValues = recentData
                .Where(s => s.Type == "pollution" && double.TryParse(s.Value, out _))
                .Select(s => double.Parse(s.Value))
                .ToList();

            var trafficValues = recentData
                .Where(s => s.Type == "traffic" && double.TryParse(s.Value, out _))
                .Select(s => double.Parse(s.Value))
                .ToList();

            double pollutionAvg = pollutionValues.Any() ? pollutionValues.Average() : 0;
            string airQualityStatus = pollutionAvg switch
            {
                <= 50 => "Good",
                <= 100 => "Moderate",
                <= 200 => "Unhealthy",
                _ => "Hazardous"
            };

            double trafficAvg = trafficValues.Any() ? trafficValues.Average() : 0;
            string trafficStatus = trafficAvg switch
            {
                < 20 => "Clear",
                < 60 => "Moderate",
                _ => "Congested"
            };

            int activeSensors = recentData.Select(s => s.Sensor_id).Distinct().Count();

            // Get the very latest weather reading from our fetched batch
            var latestWeather = rawLatestData.FirstOrDefault(s => s.Type == "weather");

            return Ok(new
            {
                Insights = new
                {
                    AirQuality = new { Status = airQualityStatus, Average = Math.Round(pollutionAvg, 1) },
                    Traffic = new { Status = trafficStatus, Average = Math.Round(trafficAvg, 0) },
                    SystemHealth = new { ActiveSensors = activeSensors, TotalReadingsLastHour = recentData.Count }
                },
                LatestWeather = latestWeather,
                LastUpdated = now
            });
        }

        [HttpGet("history")]
        [Authorize]
        public async Task<IActionResult> GetHistory(
            [FromQuery] string? type,
            [FromQuery] string? sensorId,
            [FromQuery] DateTime? from,
            [FromQuery] DateTime? to)
        {
            var query = _context.SensorData.AsQueryable();

            // Apply basic filters first
            if (!string.IsNullOrEmpty(type) && type != "All")
            {
                query = query.Where(s => s.Type == type);
            }

            if (!string.IsNullOrEmpty(sensorId))
            {
                query = query.Where(s => s.Sensor_id == sensorId);
            }

            // CRITICAL SPEED FIX:
            // Order by ID (Indexed) and strictly limit to 1000.
            // We ignore the database date sort to prevent timeouts.
            var result = await query
                .OrderByDescending(s => s.Id)
                .Take(1000)
                .ToListAsync();

            // Optional: Refine the 1000 results by date in memory if user requested a specific range
            if (from.HasValue || to.HasValue)
            {
                string startStr = (from ?? DateTime.MinValue).ToString("yyyy-MM-ddTHH:mm:ss");
                string endStr = (to ?? DateTime.MaxValue).ToString("yyyy-MM-ddTHH:mm:ss");

                result = result
                    .Where(s => string.Compare(s.Timestamp, startStr) >= 0 &&
                                string.Compare(s.Timestamp, endStr) <= 0)
                    .ToList();
            }

            return Ok(result);
        }
    }
}