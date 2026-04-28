FROM python:3.9-slim

# Install system dependencies
RUN apt-get clean && apt-get -y update && \
    apt-get -y install nginx python3-dev build-essential nfs-common && \
    rm -rf /var/lib/apt/lists/*

# Create mount point for NFS
RUN mkdir -p /nfs

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Expose port 5000 for the application
EXPOSE 5000

# Command to run the application
CMD ["python3", "main.py"]
