"""
Simple backend server for Smart CityOps simulator
Listens on http://localhost:5000/sensor-data and prints received JSON data.

How to run:
1. Install Flask if not already installed:
   pip install flask
2. Run the server:
   python backend.py
"""
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

# Store received sensor data in memory
received_data = []

@app.route('/sensor-data', methods=['POST'])
def sensor_data():
    data = request.get_json(force=True, silent=True)
    if not data:
        return jsonify({"error": "No JSON received"}), 400
    received_data.append(data)
    print(f"[Backend] Received: {data}")
    return jsonify({"status": "success"}), 200

@app.route('/', methods=['GET'])
def index():
    table_html = '''
    <html>
    <head><title>Smart CityOps Backend</title></head>
    <body>
    <h2>Received Sensor Data</h2>
    <table border="1" cellpadding="5" cellspacing="0">
        <tr>
            <th>Sensor ID</th>
            <th>Type</th>
            <th>Value</th>
            <th>Timestamp</th>
        </tr>
        {% for item in data %}
        <tr>
            <td>{{ item['sensor_id'] }}</td>
            <td>{{ item['type'] }}</td>
            <td>{{ item['value'] }}</td>
            <td>{{ item['timestamp'] }}</td>
        </tr>
        {% endfor %}
    </table>
    <p>Use POST /sensor-data to send data.</p>
    </body>
    </html>
    '''
    return render_template_string(table_html, data=received_data)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
