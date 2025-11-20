"""
Smart CityOps Phase 3: Dockerized Backend Service
- Receives JSON data from simulators via HTTP POST
- Processes data: calculates averages, triggers alerts
- Stores data in SQLite
- Ready for Dockerization and future AWS/SQS integration
"""
import sqlite3
from flask import Flask, request, jsonify, render_template_string
from threading import Lock
import statistics

app = Flask(__name__)
db_lock = Lock()

# SQLite setup
DB_FILE = 'sensor_data.db'
conn = sqlite3.connect(DB_FILE, check_same_thread=False)
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS sensor_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sensor_id TEXT,
    type TEXT,
    value TEXT,
    timestamp TEXT
)''')
conn.commit()

# Thresholds for alerts
TRAFFIC_ALERT = 80      # Congestion level
POLLUTION_ALERT = 300   # Pollution index

# Store last N values for average calculation
LAST_N = 20
sensor_values = {"traffic": [], "pollution": [], "weather": []}

@app.route('/sensor-data', methods=['POST'])
def sensor_data():
    data = request.get_json(force=True, silent=True)
    if not data:
        return jsonify({"error": "No JSON received"}), 400
    # Store in DB
    with db_lock:
        c.execute("INSERT INTO sensor_data (sensor_id, type, value, timestamp) VALUES (?, ?, ?, ?)",
                  (data['sensor_id'], data['type'], str(data['value']), data['timestamp']))
        conn.commit()
    # Update in-memory values
    sensor_type = data['type']
    sensor_values.setdefault(sensor_type, [])
    sensor_values[sensor_type].append(data['value'])
    if len(sensor_values[sensor_type]) > LAST_N:
        sensor_values[sensor_type].pop(0)
    # Alert logic
    alert = None
    if sensor_type == "traffic" and isinstance(data['value'], int) and data['value'] >= TRAFFIC_ALERT:
        alert = f"Traffic Alert! Congestion level: {data['value']}"
    if sensor_type == "pollution" and isinstance(data['value'], int) and data['value'] >= POLLUTION_ALERT:
        alert = f"Pollution Alert! Index: {data['value']}"
    return jsonify({"status": "success", "alert": alert}), 200

@app.route('/', methods=['GET'])
def index():
    # Calculate averages
    averages = {}
    for t, vals in sensor_values.items():
        try:
            # Weather values are dicts, handle separately
            if t == "weather" and vals:
                temp = [v['temperature'] for v in vals if isinstance(v, dict) and 'temperature' in v]
                humidity = [v['humidity'] for v in vals if isinstance(v, dict) and 'humidity' in v]
                wind = [v['wind_speed'] for v in vals if isinstance(v, dict) and 'wind_speed' in v]
                averages[t] = {
                    "temperature": round(statistics.mean(temp), 2) if temp else None,
                    "humidity": round(statistics.mean(humidity), 2) if humidity else None,
                    "wind_speed": round(statistics.mean(wind), 2) if wind else None
                }
            elif vals:
                averages[t] = round(statistics.mean([float(v) for v in vals if isinstance(v, (int, float, str))]), 2)
            else:
                averages[t] = None
        except Exception:
            averages[t] = None
    # Render table from DB
    with db_lock:
        c.execute("SELECT sensor_id, type, value, timestamp FROM sensor_data ORDER BY id DESC LIMIT 50")
        rows = c.fetchall()
    table_html = '''
    <html>
    <head><title>Smart CityOps Backend</title></head>
    <body>
    <h2>Received Sensor Data (last 50)</h2>
    <table border="1" cellpadding="5" cellspacing="0">
        <tr>
            <th>Sensor ID</th>
            <th>Type</th>
            <th>Value</th>
            <th>Timestamp</th>
        </tr>
        {% for item in rows %}
        <tr>
            <td>{{ item[0] }}</td>
            <td>{{ item[1] }}</td>
            <td>{{ item[2] }}</td>
            <td>{{ item[3] }}</td>
        </tr>
        {% endfor %}
    </table>
    <h3>Averages</h3>
    <ul>
    {% for t, avg in averages.items() %}
        <li>{{ t }}: {{ avg }}</li>
    {% endfor %}
    </ul>
    <p>Use POST /sensor-data to send data.</p>
    </body>
    </html>
    '''
    return render_template_string(table_html, rows=rows, averages=averages)

# For extension: add more processing, DB integration, or SQS support here

import threading
import random
import time
from datetime import datetime

def auto_generate_data():
    sensor_types = ["traffic", "pollution", "weather"]
    while True:
        sensor_type = random.choice(sensor_types)
        sensor_id = f"{sensor_type}_{random.randint(1, 10):03d}"
        if sensor_type == "traffic":
            value = random.randint(0, 100)
        elif sensor_type == "pollution":
            value = random.randint(0, 500)
        else:
            value = {
                "temperature": round(random.uniform(-10, 40), 1),
                "humidity": round(random.uniform(10, 100), 1),
                "wind_speed": round(random.uniform(0, 20), 1)
            }
        timestamp = datetime.utcnow().isoformat() + "Z"
        data = {
            "sensor_id": sensor_id,
            "type": sensor_type,
            "value": value,
            "timestamp": timestamp
        }
        # Store in DB and update in-memory values
        with db_lock:
            c.execute("INSERT INTO sensor_data (sensor_id, type, value, timestamp) VALUES (?, ?, ?, ?)",
                      (data['sensor_id'], data['type'], str(data['value']), data['timestamp']))
            conn.commit()
        sensor_values.setdefault(sensor_type, [])
        sensor_values[sensor_type].append(data['value'])
        if len(sensor_values[sensor_type]) > LAST_N:
            sensor_values[sensor_type].pop(0)
        time.sleep(5)  # Send every 5 seconds

if __name__ == '__main__':
    threading.Thread(target=auto_generate_data, daemon=True).start()
    app.run(host='0.0.0.0', port=5000)
