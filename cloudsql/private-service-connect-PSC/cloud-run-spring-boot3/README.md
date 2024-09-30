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

1. Build the project:
   ```
   mvn clean package
   ```

2. Run the application:
   ```
   java -jar target/demo-cloudsql.jar
   ```

## Docker

A Dockerfile is provided to containerize the application:

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/demo-cloudsql.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build the Docker image:
```
docker build -t demo-cloudsql .
```

Run the Docker container:
```
docker run -p 8080:8080 demo-cloudsql
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