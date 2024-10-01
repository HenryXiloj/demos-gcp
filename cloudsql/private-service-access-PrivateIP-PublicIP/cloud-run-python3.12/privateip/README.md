# Cloud SQL Connector Flask App

This project demonstrates a Flask application that connects to a Cloud SQL PostgreSQL instance using the Cloud SQL Python Connector with Private Service Connect (PSC).

## Project Structure

```
.
├── Dockerfile
├── main.py
├── README.md
└── requirements.txt
```

## Prerequisites

- Python 3.12
- A Google Cloud Platform account with a Cloud SQL PostgreSQL instance set up
- Necessary credentials for connecting to Cloud SQL (e.g., service account key)

## Setup

1. Clone this repository:
   ```
   git clone <repository-url>
   cd <repository-name>
   ```

2. Set up your Cloud SQL instance connection details in `main.py`:
   - Replace `<PROJECT-ID>:<REGION>:psc-instance` with your actual instance connection name
   - Update the `user`, `password`, and `db` fields with your database credentials


3. Set the `INSTANCE_CONNECTION_NAME` environment variable in the Dockerfile:
   ```dockerfile
   ENV INSTANCE_CONNECTION_NAME="<PROJECT-ID>:<REGION>:psc-instance"
   ```

## Running the Application

### 4. Build and Push the Docker Image
```bash
docker build -t quickstart-python:1.0.1 .
```
```bash
docker tag quickstart-python:1.0.1 us-central1-docker.pkg.dev/MY_PROJECT_ID/my-repo/quickstart-python:1.0.1
```
```bash
docker push us-central1-docker.pkg.dev/MY_PROJECT_ID/my-repo/quickstart-python:1.0.1 
```

### 5. Deploy to Cloud Run
```bash
gcloud run deploy python-cloudsql-run \
  --image us-central1-docker.pkg.dev/<PROJECT-ID>/my-repo/quickstart-python:1.0.1 \
  --region=us-central1 \
  --allow-unauthenticated \
  --service-account=cloudsql-service-account-id@<PROJECT-ID>.iam.gserviceaccount.com \
  --vpc-connector private-cloud-sql 
```

## API Endpoints

- `/`: Returns a "Hello World" message
- `/db-version`: Queries the database and returns the PostgreSQL version

## Logging

The application uses Python's logging module to log debug, info, and error messages. Logs are output to the console.

## Environment Variables

- `PORT`: The port on which the Flask app runs (default: 8080)
- `NAME`: Used in the hello world message (default: "World")

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.