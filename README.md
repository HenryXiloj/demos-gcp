Demos GCP Repository
====================

This repository contains various demo projects showcasing how to use Google Cloud services like Cloud SQL, VPC networks, and more, along with tools like Terraform, Spring Boot, Flask, and Docker for infrastructure and application deployment.

Projects Overview
-----------------

1.  **Terraform GCP Infrastructure Setup**
    
    *   This demo project uses Terraform to provision Google Cloud resources such as VPC networks, subnets, firewalls, Cloud SQL instances, and more.
        
    *   Key Features:
        
        *   Private Service Connect (PSC) for Cloud SQL
            
        *   VPC and NAT Gateway configuration
            
        *   IAM roles and permissions management
            
    *   More details in the project README
        
2.  **Spring Boot Cloud SQL with Private Service Connect**
    
    *   A Spring Boot 3 application built with Java 17, demonstrating the use of Cloud SQL PostgreSQL with Private Service Connect for secure database access.
        
    *   Key Features:
        
        *   PostgreSQL integration via PSC
            
        *   Dockerized application for easy deployment
            
        *   REST API with basic CRUD operations
            
    *   More details in the project README
        
3.  **Flask App with Cloud SQL Connector**
    
    *   This project shows how to use the Cloud SQL Python Connector with a Flask application to connect to a PostgreSQL instance using Private Service Connect.
        
    *   Key Features:
        
        *   Python Flask app with GCP integration
            
        *   Secure Cloud SQL connection using the Cloud SQL Python Connector
            
        *   Dockerized application for local or cloud-based deployment
            
    *   More details in the project README
        
4.  **Private and Public IP Cloud SQL Demo**
    
    *   A Terraform configuration to deploy Cloud SQL instances with both public and private IPs, along with a Spring Boot application demonstrating how to connect to both instances.
        
    *   Key Features:
        
        *   Cloud SQL with Private Service Connect and public IP
            
        *   Secure IAM roles and firewall rules
            
        *   Application configurations for both types of IPs
            
    *   More details in the project README
        
5.  **Spring Boot Demo with Cloud SQL (Public and Private IP)**
    
    *   A Spring Boot project that demonstrates connecting to Cloud SQL instances using both public and private IPs, with a focus on containerization using Docker.
        
    *   Key Features:
        
        *   Private Service Connect (PSC) for enhanced security
            
        *   Public IP-based database access for flexibility
            
        *   Docker for easy deployment and scalability
            
    *   More details in the project README
        

Common Setup Instructions
-------------------------

### Prerequisites

*   Terraform installed and configured for GCP projects.
    
*   Google Cloud SDK installed and authenticated.
    
*   [Java 17](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html), [Maven](https://maven.apache.org/install.html), and Docker for application development and containerization.
    

### Running Terraform Projects

1.  Clone the repository.
    
2.  Navigate to the desired project directory.
    
3.  bashCopy codeterraform initterraform apply
    

### Running Spring Boot or Flask Applications

1.  bashCopy codemvn clean packageorbashCopy codepip install -r requirements.txt
    
2.  bashCopy codedocker build -t .docker run -p 8080:8080
    

Key GCP Services Used
---------------------

*   **VPC Networks**: Custom VPC networks for secure and isolated cloud environments.
    
*   **Cloud SQL (PostgreSQL)**: Managed relational databases with Private Service Connect for secure access.
    
*   **IAM Roles and Permissions**: Fine-grained access control for resources and service accounts.
    
*   **Private Service Connect (PSC)**: Private access to GCP services, enhancing security and compliance.
    

This README provides a high-level overview of the demo projects and the infrastructure setup involved in deploying applications with Google Cloud services. For more detailed information, please refer to the individual project READMEs.