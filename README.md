# Voting Application

A simple 2-tier Flask voting application that works with both local SQLite and AWS RDS.

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

## Features

- Cast votes for different candidates
