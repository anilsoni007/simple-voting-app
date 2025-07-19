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
