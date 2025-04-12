# Google Cloud Dataflow Terraform Project

This repository contains Terraform configurations and resources to set up Google Cloud Dataflow jobs that process customer data from Cloud Storage to BigQuery and Pub/Sub.

## Project Overview

This project demonstrates four different approaches to process customer data using Google Cloud Dataflow:

1. CSV to BigQuery using JavaScript transformation (Flex Template)
2. JSON to BigQuery using Xlang with Python UDF support (Flex Template)
3. JSON to BigQuery using standard template
4. JSON to Pub/Sub using standard template

## Files Structure

```
├── resources/
│   ├── bq_customers_schema.json  # BigQuery schema definition
│   ├── customers.csv             # Sample customer data in CSV format
│   ├── customers.js              # JavaScript transformation function
│   └── customers.json            # Sample customer data in JSON format
├── iam.tf                        # IAM roles and service account configuration
├── main.tf                       # Main Terraform configuration
├── provider.tf                   # Terraform provider configuration
├── terraform.tfvars              # Terraform variables values
└── variable.tf                   # Terraform variables declaration
```

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- Google Cloud Project with billing enabled
- Service account with necessary permissions

## Setup

1. Replace `<PROJECT_ID>` in `terraform.tfvars` with your actual Google Cloud Project ID.

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Apply the Terraform configuration:
   ```
   terraform apply
   ```

## Dataflow Job Details

### 1. First Job (JavaScript Transform CSV)
Uses the `GCS_Text_to_BigQuery_Flex` template to process CSV data with JavaScript transformation.

### 2. Second Job (JSON with Xlang)
Uses the `GCS_Text_to_BigQuery_Xlang` template to process JSON data with Python UDF support.

### 3. Third Job (Standard JSON to BigQuery)
Uses the standard `GCS_Text_to_BigQuery` template to process JSON data.

### 4. Fourth Job (JSON to Pub/Sub)
Uses the `GCS_Text_to_Cloud_PubSub` template to publish JSON data to a Pub/Sub topic.

## Resources Created

- Storage bucket for customer data and temporary files
- BigQuery dataset and table for customer data
- Pub/Sub topic for streaming data
- Service account with necessary IAM roles
- Four Dataflow jobs with different configurations

## IAM Permissions

The Dataflow service account is granted the following roles:
- Storage Object Admin
- Dataflow Admin
- BigQuery Admin
- Pub/Sub Admin

## Cleaning Up

To avoid incurring charges, delete all resources when not needed:

```
terraform destroy
```

## Additional Commands

You can also run the Dataflow jobs manually using the gcloud commands provided in the Terraform files.

## Notes

- The Terraform configuration uses both classic and flex templates for demonstration purposes.
- Make sure your project has the necessary APIs enabled (Dataflow, BigQuery, Storage, Pub/Sub).