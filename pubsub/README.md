# Integrating Google Cloud Pub/Sub with Terraform and Spring Boot 3 (Java 21)

## Overview
This project demonstrates how to provision Google Cloud Pub/Sub resources using Terraform and integrate them with a Spring Boot 3 application running Java 21. The setup enables seamless message publishing and subscription processing in a cloud-native environment.

## Features
- Infrastructure as Code (IaC) with Terraform
- Google Cloud Pub/Sub Topic and Subscription
- Spring Boot 3 application for message publishing and subscription
- Pub/Sub integration using `spring-cloud-gcp-starter-pubsub`

## Prerequisites
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Java 21](https://adoptium.net/temurin/releases/)
- [Maven](https://maven.apache.org/download.cgi)
- Google Cloud credentials with Pub/Sub permissions

## Infrastructure Setup with Terraform

### Configure Terraform Provider
```hcl
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
```

### Deploy Terraform Configuration
```sh
git clone https://github.com/HenryXiloj/demos-gcp.git
cd demos-gcp/pubsub
terraform init
terraform apply -auto-approve
```

## Running the Spring Boot Application

### Set Environment Variables
```sh
export GOOGLE_APPLICATION_CREDENTIALS=mypath/application_default_credentials.json
export GOOGLE_EXTERNAL_ACCOUNT_ALLOW_EXECUTABLES=1
```

### Start the Application
```sh
mvn spring-boot:run
```

## Testing the Application
### Publish a Message
- Open `http://localhost:8080`
- Enter a message in the form and click **Publish!**


## GitHub Repository
Find the full code on GitHub: [GitHub - HenryXiloj/demos-gcp](https://github.com/HenryXiloj/demos-gcp/tree/main/pubsub)


## Contact
- **LinkedIn**: [Henry Xiloj Herrera](https://www.linkedin.com/in/henry-xiloj-herrera)
- **Blog**: [henryxiloj.com](https://jarmx.blogspot.com/)

