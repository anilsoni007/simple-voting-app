FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Update packages and install security updates
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install dependencies first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir cryptography

# Copy application files
COPY app.py db_migration.py ./
COPY templates/ templates/

# Create instance directory and set permissions
RUN mkdir -p instance && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 5000

# Run migration script before starting the app
CMD ["sh", "-c", "python db_migration.py && python app.py"]