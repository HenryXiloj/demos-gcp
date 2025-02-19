# Connecting Airflow 2 in Composer 3 to Cloud SQL via Private Service Connect (PSC) VPC Network.

This project demonstrates how to connect Airflow 2 in Google Cloud Composer 3 to a Cloud SQL instance using Private Service Connect (PSC). It uses Terraform to set up the necessary infrastructure and provides instructions for configuring and running the connection.

## Prerequisites

- Google Cloud Platform account
- Terraform installed
- `gcloud` CLI installed and configured
- Access to Google Cloud Composer and Cloud SQL

### Setup

### Option using cloud sql proxy
1. Clone this repository to your local machine. if you using this option follown all bellow steps

2. Download the Cloud SQL Proxy binary:
   ```bash
   URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.13.0"
   curl "$URL/cloud-sql-proxy.linux.amd64" -o cloud-sql-proxy
   chmod +x cloud-sql-proxy
   ```

### Terraform setup 

3. Update the `terraform.tfvars` file with your project details:
   ```hcl
   project_id     = "<my-project-id>"
   project_number = "<my-project-number>"
   region         = "us-central1"
   zone           = "us-central1-a"
   sec_region     = "us-west1"
   sec_zone       = "us-west1-a"
   ```
4. First, run `terraform apply` with the Composer 3 resource, but without the network configuration in `composer.tf`. It seems that Terraform may not have completed its internal setup, or there might be an issue related to Composer v3 on GCP. In step 9, add the network configuration.

 ```bash
    #network         = google_compute_network.nw1-vpc.id
    #subnetwork      = google_compute_subnetwork.nw1-subnet1.id
 ```
    
5. Initialize Terraform and apply the configuration:
   ```bash
   terraform init
   terraform fmt
   terraform validate
   terraform plan
   terraform apply -auto-approve
   ```

6. Upload the Cloud SQL Proxy binary to a Google Cloud Storage bucket:
   ```bash
   gsutil cp cloud-sql-proxy gs://<my-bucket-name>
   ```
   
7. Create a Private Service Connect endpoint:

   ```bash
   gcloud sql instances describe psc-instance --project <PROJECT-ID>
   ```

   ```bash
   gcloud compute forwarding-rules create psc-service-attachment-link --address=internal-address --project=<PROJECT-ID> --region=us-central1 --network=nw1-vpc --target-service-attachment=<pscServiceAttachmentLink>
   ```

   ```bash
   gcloud compute forwarding-rules describe psc-service-attachment-link --project <PROJECT-ID>  --region us-central1
   ```  

8. Configure a DNS managed zone and a DNS record: 
   ```bash
   gcloud dns managed-zones create cloud-sql-dns-zone --project=<PROJECT-ID> --description="DNS zone for the Cloud SQL instance" --dns-name=<DNS-ENTRY> --networks=nw1-vpc --visibility=private
   ```

   ```bash
   gcloud dns record-sets create <DNS-ENTRY> --project=<PROJECT-ID> --type=A --rrdatas=10.10.1.10 --zone=cloud-sql-dns-zone
   ```
       
9. Add the network configuration in `composer.tf`: 
     ```bash
       network         = google_compute_network.nw1-vpc.id
       subnetwork      = google_compute_subnetwork.nw1-subnet1.id
     ```
10. Then run `terraform apply` again: 
      ```bash
      terraform apply -auto-approve
      ```       

### Option using cloud sql connect direclty with IP address

## Note: 
 If using this option omit the next steps 1,2 and 6. and using `cloud_sql_proxy_psc_dag.py` 

## Composer Configuration

Composer v3 will automatically create a bucket with the following structure:
```
<region>-<my-composer-name-ID>-bucket/
├── dags/
├── data/
├── logs/
└── plugins/
```

## Python script configuration

Go to: `resources/cloud_sql_proxy_psc_dag.py`

1. Update the `cloud_sql_proxy_psc_dag.py` file with your project details:
   ```bash
   GCS_BUCKET_NAME = "<my-bucket>"
   BINARY_NAME = "<my-bynary-name>" ## cloud-sql-proxy
   INSTANCE_CONNECTION_NAME = "<project-id>:<my-region>:<instance-name>" 
   ```
## Upload `cloud_sql_proxy_psc_dag.py`

Upload your `cloud_sql_proxy_psc_dag.py` file to the `dags/` directory using `gsutil` or manually through the Google Cloud Console.

## Running the DAG

1. Access the Airflow 2 UI through Google Cloud Composer.
2. Locate your uploaded DAG in the DAGs list.
3. Enable and trigger the DAG to run.

## Project Structure

- `provider.tf`: Defines the required providers and their versions.
- `variable.tf`: Declares variables used throughout the Terraform configuration.
- `terraform.tfvars`: Sets values for the declared variables.
- `network.tf`: Configures the VPC network and subnets.
- `compute.tf`: Sets up compute resources, including internal IP addresses.
- `iam.tf`: Manages IAM roles and service accounts.
- `bucket.tf`: Creates a Google Cloud Storage bucket for the Cloud SQL Proxy binary.
- `main.tf`: Configures the Cloud SQL instance with PSC connectivity.
- `composer.tf`: Sets up the Google Cloud Composer environment.

## Delete configuration

1. Delete a DNS managed zone and a DNS record: 
   
   ```bash
   gcloud dns record-sets delete <DNS-ENTRY> --type=A --zone=cloud-sql-dns-zone
   ``` 

   ```bash
   gcloud dns managed-zones delete cloud-sql-dns-zone --project=<PROJECT-ID>
   ```
   
2. Delete a Private Service Connect endpoint:

```bash
   gcloud compute forwarding-rules delete psc-service-attachment-link --region=us-central1  --project=<PROJECT-ID>
```    
3. Terraform destroy:

```bash
   terrafrom destroy -auto-approve
```      

## Troubleshooting

If you encounter any issues:
1. Ensure comment networks config in first run terraform apply, otherwise you get network issue. 
2. Check the Airflow logs in the Composer environment.
3. Verify that all resources have been created correctly in the Google Cloud Console.
4. Ensure that the Cloud SQL Proxy binary is correctly uploaded and accessible.
5. Double-check the IAM permissions for the Composer service account.

## Images

For visual reference:

1.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psc/img1.png?raw=true?raw=true)

2.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psc/img2.png?raw=true?raw=true)

3.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psc/img3.png?raw=true?raw=true)

4.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psc/img4.png?raw=true?raw=true)

5.
![alt text](https://github.com/HenryXiloj/demos-gcp/blob/main/cloudsql/composer-v3-cloud-sql-psc/img5.png?raw=true?raw=true)

