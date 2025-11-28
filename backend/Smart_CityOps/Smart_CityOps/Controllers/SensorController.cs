using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Smart_CityOps.Data;
using Smart_CityOps.Models;
using System.Text.Json;

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

        [HttpGet("latest-data")]
        [Authorize(Roles = UserRoles.Admin)]
        public async Task<IActionResult> GetSummary()
        {
            var data = await _context.SensorData
                .GroupBy(s => s.Type)
                .Select(g => g.OrderByDescending(s => s.Timestamp).FirstOrDefault())
                .ToListAsync();
            return Ok(data);
        }




        [HttpGet("type/{type}")]
        [Authorize(Roles = UserRoles.Admin)]
        public async Task<IActionResult> GetByType(string type)
        {
            var data = await _context.SensorData
                .Where(s => s.Type == type)
                .OrderByDescending(s => s.Timestamp)
                .Take(20)
                .ToListAsync();

            if (!data.Any()) return NotFound($"No data found for type: {type}");

            return Ok(data);
        }



        [HttpGet("weather/current")]
        [Authorize(Roles = UserRoles.Admin)]
        public async Task<IActionResult> GetCurrentWeather()
        {
            var rawWeather = await _context.SensorData
                .Where(s => s.Type == "weather")
                .OrderByDescending(s => s.Timestamp)
                .FirstOrDefaultAsync();

            if (rawWeather == null || rawWeather.Value == null)
                return NotFound("No weather data available");

            try
            {
                var weatherObj = JsonSerializer.Deserialize<object>(rawWeather.Value);

                return Ok(new
                {
                    id = rawWeather.Id,
                    timestamp = rawWeather.Timestamp,
                    data = weatherObj
                });
            }
            catch
            {
                return BadRequest("Error parsing weather data");
            }
        }
    }
}