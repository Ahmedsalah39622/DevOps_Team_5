# Use official Python image
FROM python:3.10-slim

# Set work directory
WORKDIR /app

# Install Flask (sqlite3 is included in Python)
RUN pip install flask

# Copy the backend service code
COPY backend_service.py .

# Expose the port Flask runs on
EXPOSE 5000

# Run the backend
CMD ["python", "backend_service.py"]
