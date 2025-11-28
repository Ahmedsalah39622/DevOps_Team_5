using Microsoft.EntityFrameworkCore;
using Smart_CityOps.Entities;

namespace Smart_CityOps.Data
{
    public class SmartCityContext : DbContext
    {
        public SmartCityContext(DbContextOptions<SmartCityContext> options) : base(options)
        {
        }

        public DbSet<SensorData> SensorData { get; set; }
    }
}
