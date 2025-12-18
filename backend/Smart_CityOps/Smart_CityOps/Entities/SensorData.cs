using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Smart_CityOps.Entities
{
    [Table("sensor_data", Schema = "dbo")]
    public class SensorData
    {
        [Key]
        public int Id { get; set; }

        [Column("type")]
        public string? Type { get; set; }

        [Column("value")]
        public string? Value { get; set; }

        [Column("timestamp")]
        public string? Timestamp { get; set; }

        [Column("sensor_id")]
        public string? Sensor_id { get; set; }
    }
}