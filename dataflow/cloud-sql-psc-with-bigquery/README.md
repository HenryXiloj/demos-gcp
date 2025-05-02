# Cloud SQL PostgreSQL with Private Service Connect (PSC) and BigQuery Integration

This project demonstrates a secure setup for accessing Cloud SQL PostgreSQL via Private Service Connect (PSC) and loading data into BigQuery using Dataflow.

## Architecture Overview

The solution implements:

- Cloud SQL PostgreSQL instance with Private Service Connect (PSC) enabled
- VPC network with private subnet and appropriate firewall rules
- DNS configuration for private connectivity
- PostgreSQL to BigQuery data pipeline using Dataflow
- Service accounts with appropriate IAM roles

## Prerequisites

- Google Cloud account with billing enabled
- Terraform installed locally
- Google Cloud SDK (gcloud) installed
- Appropriate permissions to create resources in Google Cloud

## Project Structure

```
cloud-sql-psc-with-bigquery/
├── terraform/               # Infrastructure as code
│   ├── compute.tf           # Compute resources (forwarding rules for PSC)
│   ├── dns.tf               # DNS configuration for private connectivity
│   ├── iam.tf               # Service accounts and IAM permissions
│   ├── main.tf              # Main resources (Cloud SQL, BigQuery)
│   ├── network.tf           # VPC, subnet, and firewall rules
│   ├── provider.tf          # Terraform provider configuration
│   ├── terraform.tfvars     # Variable values
│   └── variable.tf          # Variable definitions
├── sql/                     # SQL initialization scripts
│   └── init_customers.sql   # Sample customer data initialization
└── postgresql_to_bq_flex_template/  # Dataflow template 
    ├── main.py              # Pipeline code for PostgreSQL to BigQuery
    ├── metadata.json        # Template metadata
    └── requirements.txt     # Python dependencies
```

## Deployment Instructions

### Step 1: Deploy Infrastructure with Terraform

1. Navigate to the terraform directory:
   ```bash
   cd cloud-sql-psc-with-bigquery/terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the Terraform configuration:
   ```bash
   terraform apply -auto-approve
   ```

   This will create:
   - A Cloud SQL PostgreSQL instance with PSC enabled
   - A read replica in a secondary region
   - VPC network, subnet, and firewall rules
   - Private Service Connect configurations
   - DNS configurations for private access
   - BigQuery dataset and tables
   - Service accounts with required permissions
   - Cloud Storage bucket for data and artifacts

### Step 2: Configure PostgreSQL Database

1. Navigate to the Cloud SQL section in the Google Cloud Console
2. Select the instance `psc-instance-test`
3. Go to Databases and select `my-database4`
4. Open Cloud SQL Studio and use the following credentials:
   - User: henry
   - Password: hxi123
5. Execute the initialization script:
   ```sql
   -- Copy and paste contents from init_customers.sql
   ```
   
   Alternatively, you can navigate to the SQL tab and upload the SQL file.

### Step 3: Download SSL Certificates

1. In the Cloud SQL console, select the `psc-instance-test` instance
2. Navigate to Connections → Security → "Manage certificates"
3. Create a new CA certificate by clicking "Create client certificate"
4. Download the three certificate files:
   - server-ca.pem (server CA certificate)
   - client-cert.pem (client certificate)
   - client-key.pem (client key)

5. Upload these certificates to Cloud Storage:
   ```bash
   gcloud storage cp server-ca.pem client-cert.pem client-key.pem gs://${PROJECT_ID}-data-bucket/
   ```
   Replace `${PROJECT_ID}` with your actual project ID

### Step 4: Build and Deploy Dataflow Flex Template

1. Navigate to the `postgresql_to_bq_flex_template` directory:
   ```bash
   cd ../postgresql_to_bq_flex_template
   ```

2. Build and push the container image:
   ```bash
   gcloud builds submit --tag gcr.io/${PROJECT_ID}/postgres-to-bq-flex
   ```

Replace `${PROJECT_ID}` with your actual project ID

3. Create the Flex Template:
   ```bash
   gcloud dataflow flex-template build gs://${PROJECT_ID}-data-bucket/templates/postgres_to_bq_flex.json \
     --image gcr.io/${PROJECT_ID}/postgres-to-bq-flex \
     --sdk-language PYTHON \
     --metadata-file metadata.json
   ```

Replace `${PROJECT_ID}` with your actual project ID

4. Run the Dataflow pipeline:
   ```bash
   gcloud dataflow flex-template run "pg-to-bq-$(date +%Y%m%d-%H%M%S)" \
     --template-file-gcs-location=gs://${PROJECT_ID}-data-bucket/templates/postgres_to_bq_flex.json \
     --project=${PROJECT_ID} \
     --region=us-central1 \
     --subnetwork regions/us-central1/subnetworks/nw1-vpc-sub1-us-central1 \
     --service-account-email=dataflow-service-account-id@${PROJECT_ID}.iam.gserviceaccount.com \
     --parameters="output_table=${PROJECT_ID}:sample_dataset.customers,failed_table=${PROJECT_ID}:sample_dataset.failed_customers,gcs_ssl_path=gs://${PROJECT_ID}-data-bucket,psc_host=<YOUR_PSC_HOST>,db_name=my-database4,db_user=henry,db_pass=hxi123"
   ```

   > **Note:** Replace `<YOUR_PSC_HOST>` with your actual PSC hostname. You can find this in the Cloud SQL instance details under "Connections" tab. Replace `${PROJECT_ID}` with your actual project ID

## How It Works

1. **Private Service Connect (PSC)**: Enables private connectivity to Cloud SQL without external IP exposure
2. **DNS Configuration**: Provides name resolution for the PSC endpoint
3. **Secure Connection**: Uses SSL certificates for encrypted database access
4. **Dataflow Pipeline**: Reads data from PostgreSQL and loads it into BigQuery
5. **IAM Security**: Uses service accounts with least privilege permissions

## Troubleshooting

### Common Issues:

1. **PSC Connectivity**:
   - Ensure the VPC has proper connectivity to the PSC endpoint
   - Verify DNS resolution for the PSC hostname
   - Check firewall rules allow PostgreSQL traffic (port 5432)

2. **SSL Certificate Issues**:
   - Ensure certificates are uploaded to the correct GCS location
   - Verify certificate permissions (client-key.pem should be 0600)

3. **Dataflow Pipeline Failures**:
   - Check service account permissions
   - Validate network connectivity from the Dataflow workers
   - Review pipeline logs for specific error messages

## Cleanup

To delete all resources when you're done:

```bash
cd terraform
terraform destroy -auto-approve
```

This will remove all created resources except for any manually created artifacts.

## Security Considerations

- Cloud SQL is configured with no public IP
- SSL is required for connections
- IAM authentication is enabled
- Service accounts follow principle of least privilege
- Network is secured with appropriate firewall rules