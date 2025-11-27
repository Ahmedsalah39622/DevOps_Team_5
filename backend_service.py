# app.py - Pure JSON API for Smart City Backend (AWS ECS Fargate ready)
import pyodbc
import json
import os
import time
from datetime import datetime
import random

# SQL Server connection details from environment variables
SQL_SERVER = os.getenv("SQL_SERVER", "database-1.cu1q6k0y0k3q.us-east-1.rds.amazonaws.com")
SQL_PORT = os.getenv("SQL_PORT", "1433")
SQL_USER = os.getenv("SQL_USER", "admin")
SQL_PASSWORD = os.getenv("SQL_PASSWORD", "Br1i5&%rQ0")
SQL_DATABASE = os.getenv("SQL_DATABASE", "smartcity")
TABLE_NAME = os.getenv("TABLE_NAME", "sensor_data")

# Connection string for pyodbc
CONN_STR = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SQL_SERVER},{SQL_PORT};"
    f"DATABASE={SQL_DATABASE};"
    f"UID={SQL_USER};"
    f"PWD={SQL_PASSWORD}"
)

# Table name for backend data
TABLE_NAME = "sensor_data"  # Change if your table name is different

def insert_generated_data():
    sensor_types = ['traffic', 'pollution', 'weather']
    while True:
        sensor_id = f"sensor_{random.randint(1, 100)}"
        sensor_type = random.choice(sensor_types)
        value = {
            "traffic": random.randint(0, 100),
            "pollution": round(random.uniform(0, 500), 2),
            "weather": {
                "temperature": round(random.uniform(-10, 40), 1),
                "humidity": random.randint(10, 90),
                "wind_speed": round(random.uniform(0, 20), 1)
            }
        }[sensor_type]
        timestamp = datetime.utcnow().isoformat()

        try:
            conn = pyodbc.connect(CONN_STR)
            cursor = conn.cursor()
            cursor.execute(
                f"INSERT INTO {TABLE_NAME} (sensor_id, type, value, timestamp) VALUES (?, ?, ?, ?)",
                sensor_id, sensor_type, json.dumps(value), timestamp
            )
            conn.commit()
            conn.close()
            print(f"Inserted: {sensor_id}, {sensor_type}, {value}, {timestamp}")
        except Exception as e:
            print(f"DB insert failed: {e}")

        time.sleep(60)  # Wait 1 minute before next insert

if __name__ == "__main__":
    insert_generated_data()