# Use an official Python runtime as the base image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the required packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY main.py .

# Make sure you have the necessary credentials for connecting to Cloud SQL
# You might need to copy a service account key file if you're not using Workload Identity
# COPY your-service-account-key.json /app/service-account-key.json
# ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json

# Set the environment variable for the Cloud SQL instance connection name
#ENV INSTANCE_CONNECTION_NAME="<PROJECT-ID>:<REGION>:psc-instance"

# Run the application
CMD ["python", "main.py"]