# Demo Cloud SQL Project

This project demonstrates a Spring Boot application using Java 17 that connects to Cloud SQL PostgreSQL instances using both public IP and private IP via Private Service Connect (PSC). The application is containerized using Docker.

## Project Structure

- **Dockerfile**: Defines the Docker image for the application.
- **pom.xml**: Maven build configuration, including dependencies for Spring Boot, JPA, PostgreSQL, and Cloud SQL Socket Factory.
- **application.yml**: Configuration for connecting to Cloud SQL instances via public and private IPs.
- **data.sql**: SQL script to populate tables with initial data.
- **schema.sql**: SQL script to create tables.
- **Java classes**: Configurations and models for interacting with the Cloud SQL databases.

## Prerequisites

- Java 17
- Maven 3.x
- Docker
- Google Cloud project with Cloud SQL (PostgreSQL) instances
- Google Cloud SDK installed and authenticated

## Setup

### 1. Cloud SQL Setup

Ensure you have Cloud SQL PostgreSQL instances with the following configurations:
- One with a **public IP**.
- One with a **private IP** or **Private Service Connect (PSC)** setup.

### 2. Update application.yml

Modify the `application.yml` file with your Cloud SQL instance details:

```yaml
spring:
  datasource:
    public-ip:
      url: jdbc:postgresql:///
      database: my-database1
      cloudSqlInstance: <MY_PROJECT_ID>:us-central1:main-instance
      username: <DB_USERNAME>
      password: <DB_PASSWORD>
      ipTypes: PUBLIC
      socketFactory: com.google.cloud.sql.postgres.SocketFactory
    private-ip:
      url: jdbc:postgresql:///
      database: my-database2
      cloudSqlInstance: <MY_PROJECT_ID>:us-central1:private-instance
      username: <DB_USERNAME>
      password: <DB_PASSWORD>
      ipTypes: PRIVATE
      socketFactory: com.google.cloud.sql.postgres.SocketFactory
```
### 3. Build the project
Use Maven to build the project and generate the executable jar file:
```bash
mvn clean install
```

## Important Notes

- **Authentication to Cloud SQL**: The application uses Cloud SQL socket factory to connect securely. Ensure your Google Cloud service account has the correct IAM roles for accessing the Cloud SQL instance.
- **Database Credentials**: It is recommended to store sensitive credentials (e.g., database passwords) in Google Secret Manager or use environment variables in production.
- **Network Configuration**: Make sure that Cloud SQL's IP allowlists and VPC peering configurations are set up correctly based on the type of connection (public IP or private IP).

## Technologies Used

- Java 17
- Spring Boot 3.2.3
- PostgreSQL (with Google Cloud SQL)
- Google Cloud SQL Socket Factory
- Docker
- Maven

## License

This project is licensed under the MIT License.

