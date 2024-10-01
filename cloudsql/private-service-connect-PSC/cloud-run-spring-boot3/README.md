# Spring Boot Cloud SQL Demo

This project demonstrates a Spring Boot 3 application with Java 17, connecting to Cloud SQL (PostgreSQL) using Private Service Connect (PSC).

## Project Structure

- `src/main/java/com/henry/democloudsql/`
  - `configuration/`: Contains database configuration
  - `controller/`: REST controllers
  - `model/`: Entity classes
  - `repository/`: JPA repositories
  - `service/`: Service layer

- `src/main/resources/`
  - `application.yml`: Application configuration
  - `data.sql`: Initial data for the database
  - `schema.sql`: Database schema

## Key Components

1. **PSCpostgresConfig**: Configures the connection to Cloud SQL using Private Service Connect.
2. **Table3**: Entity representing a product with id, name, and price.
3. **Table3Repository**: JPA repository for Table3 entity.
4. **Table3ServiceImpl**: Service layer for Table3 operations.
5. **Table3Controller**: REST controller for Table3 endpoints.
6. **HelloWorldController**: Simple controller returning a hello world message.

## Setup and Configuration

1. Update `application.yml` with your Cloud SQL instance details:
   ```yaml
   spring:
     datasource:
       psc:
         cloudSqlInstance: <PROJECT-ID>:<REGION>:psc-instance
         username: your-username
         password: your-password
   ```

2. Ensure you have the necessary GCP permissions and network configurations for Private Service Connect.

## Building and Running

### 2.1. Build the project
Use Maven to build the project and generate the executable jar file:
```bash
mvn clean install
```

### 2.2. After clean install, you can build the Docker image locally using the following command:
```bash
docker build -t quickstart-springboot:1.0.1 .
```

### 2.3. To push the Docker image to the Artifact Registry, you first need to tag it with the appropriate URL:
```bash
docker tag quickstart-springboot:1.0.1 us-central1-docker.pkg.dev/<PROJECT_ID>/my-repo/quickstart-springboot:1.0.1
```

### 2.4. Push the tagged image to the Artifact Registry::
```bash
docker push us-central1-docker.pkg.dev/<PROJECT_ID>/my-repo/quickstart-springboot:1.0.1
```

### 2.5. Deploy the Spring Boot application to Google Cloud Run using the gcloud command:
```bash
gcloud run deploy springboot-cloudsql-run \
  --image us-central1-docker.pkg.dev/<PROJECT_ID>/my-repo/quickstart-springboot:1.0.1 \
  --region=us-central1 \
  --allow-unauthenticated \
  --service-account=cloudsql-service-account-id@<PROJECT-ID>.iam.gserviceaccount.com \
  --vpc-connector private-cloud-sql
```

## API Endpoints

- `GET /`: Returns a hello world message
- `GET /api/v3`: Retrieves all entries from Table3

## Dependencies

- Spring Boot 3.2.3
- Spring Data JPA
- PostgreSQL
- Cloud SQL PostgreSQL Socket Factory
- Lombok

For a complete list of dependencies, please refer to the `pom.xml` file.

## Notes

- This project uses Spring Boot's `data.sql` and `schema.sql` for database initialization.
- The application is configured to use Private Service Connect (PSC) for secure database access.
- Ensure all necessary GCP configurations are in place before deploying to production.