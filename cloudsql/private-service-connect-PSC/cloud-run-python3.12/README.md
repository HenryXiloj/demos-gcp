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

2. Install the required packages:
   ```
   pip install -r requirements.txt
   ```

3. Set up your Cloud SQL instance connection details in `main.py`:
   - Replace `<PROJECT-ID>:<REGION>:psc-instance` with your actual instance connection name
   - Update the `user`, `password`, and `db` fields with your database credentials

4. If using a service account key, uncomment and update the relevant lines in the Dockerfile:
   ```dockerfile
   COPY your-service-account-key.json /app/service-account-key.json
   ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json
   ```

5. Set the `INSTANCE_CONNECTION_NAME` environment variable in the Dockerfile:
   ```dockerfile
   ENV INSTANCE_CONNECTION_NAME="<PROJECT-ID>:<REGION>:psc-instance"
   ```

## Running the Application

### Locally

To run the application locally:

```
python main.py
```

The application will start on `http://localhost:8080`.

### Using Docker

1. Build the Docker image:
   ```
   docker build -t cloud-sql-flask-app .
   ```

2. Run the Docker container:
   ```
   docker run -p 8080:8080 cloud-sql-flask-app
   ```

The application will be accessible at `http://localhost:8080`.

## API Endpoints

- `/`: Returns a "Hello World" message
- `/db-version`: Queries the database and returns the PostgreSQL version

## Logging

The application uses Python's logging module to log debug, info, and error messages. Logs are output to the console.

## Environment Variables

- `PORT`: The port on which the Flask app runs (default: 8080)
- `NAME`: Used in the hello world message (default: "World")

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.