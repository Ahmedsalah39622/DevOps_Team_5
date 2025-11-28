using System.Text.Json.Serialization;

namespace Smart_CityOps.Entities
{
        public class SensorData
        {
            [JsonPropertyName("sensor_id")]
            public string SensorId { get; set; }

            [JsonPropertyName("type")]
            public string Type { get; set; }

            [JsonPropertyName("value")]
            public double Value { get; set; }

            [JsonPropertyName("timestamp")]
            public DateTime Timestamp { get; set; }
        }
}
