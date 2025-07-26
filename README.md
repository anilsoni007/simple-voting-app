# Voting Application

A simple 2-tier Flask voting application that works with both local SQLite and AWS RDS. The app includes voting history tracking and comprehensive logging.

## Setup

1. Install dependencies:
```
pip install -r requirements.txt
```

## Running Locally (SQLite)

```
python app.py
```
Visit http://localhost:5000

## Running with RDS

Set environment variables:
```
set RDS_ENDPOINT=your-endpoint.region.rds.amazonaws.com
set RDS_USERNAME=your-username
set RDS_PASSWORD=your-password
set RDS_DB_NAME=voting_db
python app.py
```

## Docker

### Building the Docker image
```
docker build -t voting-app .
```

### Running with Docker (SQLite)
```
docker run -p 5000:5000 voting-app
```

### Running with Docker (RDS)
```
docker run -p 5000:5000 \
  -e RDS_ENDPOINT=your-endpoint.region.rds.amazonaws.com \
  -e RDS_USERNAME=your-username \
  -e RDS_PASSWORD=your-password \
  -e RDS_DB_NAME=voting_db \
  voting-app
```

### Using Pre-built Image
```
docker run -p 5000:5000 asoni007/voting-app:latest
```

With RDS:
```
docker run -p 5000:5000 \
  -e RDS_ENDPOINT=your-endpoint.region.rds.amazonaws.com \
  -e RDS_USERNAME=your-username \
  -e RDS_PASSWORD=your-password \
  -e RDS_DB_NAME=voting_db \
  asoni007/voting-app:latest
```

## Features

- Cast votes for different candidates
- Track voting history with timestamps
- View past voting sessions
- Secure containerized deployment
- Works with both SQLite and MySQL RDS
- Health monitoring with separate liveness and readiness probes

## Health Endpoints

### `/health/live` - Liveness Probe
- **Purpose**: Checks if the application process is alive
- **Response**: Always returns 200 if process is running
- **Kubernetes Action**: Restarts container if fails
- **Use Case**: Detect crashed or deadlocked processes

### `/health/ready` - Readiness Probe
- **Purpose**: Checks if application is ready to serve traffic
- **Monitors**:
  - Database connectivity (SQLite/RDS)
  - Critical files existence (app.py, templates/index.html)
- **Response**: 200 if ready, 503 if not ready
- **Kubernetes Action**: Removes pod from service endpoints if fails
- **Use Case**: Prevent traffic routing during startup or when dependencies fail



