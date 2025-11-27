# Use official Python image
FROM python:3.10-slim

# Set work directory
WORKDIR /app

# Install system dependencies for pyodbc and ODBC driver
RUN apt-get update && \
    apt-get install -y gcc g++ gnupg2 unixodbc-dev curl && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Install Python dependencies
RUN pip install flask requests pyodbc
# Copy the backend service code
COPY backend_service.py .
COPY simulator.py .

# Expose the port Flask runs on
EXPOSE 5000

# Run the backend
CMD ["python", "backend_service.py"]
