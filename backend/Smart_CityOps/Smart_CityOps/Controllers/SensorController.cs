using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Smart_CityOps.Entities;

namespace Smart_CityOps.Controllers
{
    [Route("")]
    [ApiController]
    public class SensorController : ControllerBase
    {
        [HttpPost("sensor-data")]

        public IActionResult ReceiveSensorData([FromBody] SensorData data)
        {
            if(data == null) return BadRequest("Invalid data");
            return Ok(data);
        }

    }
}