# Connecting Airflow 2 in Composer 3 to Cloud SQL via Private Service Access (PSA) VPC Network.

This project demonstrates how to connect Airflow 2 in Google Cloud Composer 3 to a Cloud SQL instance using Private Service Access (PSA). It uses Terraform to set up the necessary infrastructure and provides instructions for configuring and running the connection.

## Prerequisites

- Google Cloud Platform account
- Terraform installed
- `gcloud` CLI installed and configured
- Access to Google Cloud Composer and Cloud SQL


### Terraform setup 

1. Update the `terraform.tfvars` file with your project details:
   ```hcl
   project_id     = "<my-project-id>"
   project_number = "<my-project-number>"
   region         = "us-central1"
   zone           = "us-central1-a"
   sec_region     = "us-west1"
   sec_zone       = "us-west1-a"
   ```
    
2. Initialize Terraform and apply the configuration:
   ```bash
   terraform init
   terraform fmt
   terraform validate
   terraform plan
   terraform apply -auto-approve
   ```

### Option using cloud sql connect direclty with IP address

1. Cloud SQL Direct IP Test:
using `check_worker_ip_dag.py` replace with your private ip address.  

2. Cloud SQL test conexion:
using `cloud_sql_connector_psc_dag.py` replace with your private ip address, db, user and password.

## Composer Configuration

Composer v3 will automatically create a bucket with the following structure:
```
<region>-<my-composer-name-ID>-bucket/
├── dags/
├── data/
├── logs/
└── plugins/
```

## Running the DAG

1. Access the Airflow 2 UI through Google Cloud Composer.
2. Locate your uploaded DAG in the DAGs list.
3. Enable and trigger the DAG to run.

## Project Structure

- `provider.tf`: Defines the required providers and their versions.
- `variable.tf`: Declares variables used throughout the Terraform configuration.
- `terraform.tfvars`: Sets values for the declared variables.
- `network.tf`: Configures the VPC network and subnets.
- `iam.tf`: Manages IAM roles and service accounts.
- `main.tf`: Configures the Cloud SQL instance with PSA connectivity.
- `composer.tf`: Sets up the Google Cloud Composer environment.

## Delete configuration

1. Terraform destroy:

```bash
   terrafrom destroy -auto-approve
```      

## Troubleshooting

If you encounter any issues:
1. Check the Airflow logs in the Composer environment.
2. Verify that all resources have been created correctly in the Google Cloud Console.
3. Double-check the IAM permissions for the Composer service account.

## Images

For visual reference:

1.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psa/img1.png?raw=true?raw=true)

2.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psa/img3.png?raw=true?raw=true)

3.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psa/img3.png?raw=true?raw=true)

4.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psa/img4.png?raw=true?raw=true)


