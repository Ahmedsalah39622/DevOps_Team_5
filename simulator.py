"""
Smart CityOps Phase 2: IoT Sensor Simulator
Simulates Traffic, Pollution, and Weather sensors.
Sends JSON data to console or via HTTP POST to a local backend.
Testing
How to add more sensors or change interval:
- Add a new class inheriting from BaseSensor or extend SENSOR_TYPES.
- Change SEND_INTERVAL or NUM_SENSORS at the top of the file.
"""
import threading
import time
import random
import json
from datetime import datetime
import requests

# Configuration
NUM_SENSORS = 10           # Number of simulators (can be 10, 50, 100...)
SEND_INTERVAL = 5          # Seconds between sends
SEND_TO_HTTP = True        # Set True to send via HTTP POST
HTTP_ENDPOINT = "http://localhost:5000/sensor-data"  # Local backend endpoint (replace with your backend URL)

SENSOR_TYPES = ["traffic", "pollution", "weather"]

class BaseSensor:
    def __init__(self, sensor_id, sensor_type):
        self.sensor_id = sensor_id
        self.type = sensor_type

    def generate_value(self):
        raise NotImplementedError

    def generate_data(self):
        return {
            "sensor_id": self.sensor_id,
            "type": self.type,
            "value": self.generate_value(),
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }

class TrafficSensor(BaseSensor):
    def generate_value(self):
        # Simulate congestion level (0-100)
        return random.randint(0, 100)

class PollutionSensor(BaseSensor):
    def generate_value(self):
        # Simulate pollution index (0-500)
        return random.randint(0, 500)

class WeatherSensor(BaseSensor):
    def generate_value(self):
        # Simulate temperature, humidity, wind speed
        return {
            "temperature": round(random.uniform(-10, 40), 1),
            "humidity": round(random.uniform(10, 100), 1),
            "wind_speed": round(random.uniform(0, 20), 1)
        }

SENSOR_CLASS_MAP = {
    "traffic": TrafficSensor,
    "pollution": PollutionSensor,
    "weather": WeatherSensor
}

def send_data(data):
    json_data = json.dumps(data)
    if SEND_TO_HTTP:
        try:
            resp = requests.post(HTTP_ENDPOINT, json=data)
            print(f"[HTTP] Sent: {json_data} | Status: {resp.status_code}")
        except Exception as e:
            print(f"[HTTP] Error: {e}")
    else:
        print(f"[Console] {json_data}")

# Future integration:
# To send data to AWS SQS, replace send_data() logic with boto3 SQS client.
# Example:
# import boto3
# sqs = boto3.client('sqs')
# sqs.send_message(QueueUrl=..., MessageBody=json_data)

def sensor_worker(sensor):
    while True:
        data = sensor.generate_data()
        send_data(data)
        time.sleep(SEND_INTERVAL)

def main():
    threads = []
    for i in range(NUM_SENSORS):
        sensor_type = random.choice(SENSOR_TYPES)
        sensor_id = f"{sensor_type}_{str(i+1).zfill(3)}"
        sensor = SENSOR_CLASS_MAP[sensor_type](sensor_id, sensor_type)
        t = threading.Thread(target=sensor_worker, args=(sensor,), daemon=True)
        threads.append(t)
        t.start()
    print(f"Started {NUM_SENSORS} sensor simulators. Sending data every {SEND_INTERVAL} seconds.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Simulation stopped.")

if __name__ == "__main__":
    main()
