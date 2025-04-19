# GCP PostgreSQL to BigQuery Data Pipeline

This project sets up a complete infrastructure in Google Cloud Platform to transfer data from a PostgreSQL database to BigQuery using Dataflow. The infrastructure includes:

- A private VPC network with appropriate firewall rules
- A Cloud SQL PostgreSQL instance with a read replica
- A BigQuery dataset and tables
- A GCS bucket for temporary storage
- Service accounts with necessary permissions
- Dataflow job configuration for data transfer

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0.0+)
- Google Cloud project with billing enabled
- Appropriate permissions to create resources

## Quick Start

### Step 1: Deploy Infrastructure with Terraform

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Update the `terraform.tfvars` file with your project information if needed:
   ```
   project_id = "your-project-id"
   region     = "us-central1"
   zone       = "us-central1-a"
   sec_region = "us-west1"
   sec_zone   = "us-west1-a"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform apply -auto-approve
   ```

5. Once the deployment is complete, note the following outputs:
   - Private IP address of the Cloud SQL instance
   - Service account email for Dataflow jobs

### Step 2: Initialize the PostgreSQL Database

1. Connect to your Cloud SQL instance using Cloud SQL Studio in the Google Cloud Console:
   - Navigate to SQL in the Google Cloud Console
   - Select your `private-instance`
   - Go to the "Databases" tab and select `my-database2`
   - Open the "Query editor" (Cloud SQL Studio)
   - Login with username `henry` and password `hxi123`

   > Note: This is for demonstration purposes only. In production environments, you would typically connect using a GCE instance in the same VPC network or through a shared VPC using Cloud SQL Auth Proxy for secure access.

2. Run the initialization script in Cloud SQL Studio:

   ```sql
   -- Create customers table
   CREATE TABLE IF NOT EXISTS public.customers (
       customer_id SERIAL PRIMARY KEY,
       first_name VARCHAR(50) NOT NULL,
       last_name VARCHAR(50) NOT NULL,
       email VARCHAR(100),
       phone VARCHAR(20),
       address TEXT,
       registration_date DATE DEFAULT CURRENT_DATE,
       loyalty_points INTEGER DEFAULT 0
   );

   -- Insert sample data
   INSERT INTO public.customers (first_name, last_name, email, phone, address)
   VALUES
       ('John', 'Doe', 'john.doe@example.com', '555-123-4567', '123 Main St'),
       ('Jane', 'Smith', 'jane.smith@example.com', '555-987-6543', '456 Oak Ave'),
       ('Michael', 'Johnson', 'michael.j@example.com', '555-567-8901', '789 Pine Rd'),
       ('Susan', 'Williams', 'susan.w@example.com', '555-345-6789', '321 Elm St'),
       ('Robert', 'Brown', 'robert.b@example.com', '555-234-5678', '654 Maple Dr');
   ```

### Step 3: Run the Dataflow Job

You can run the Dataflow job using one of the following methods:

#### Option 1: Using Cloud Shell

Get the necessary variables:

```bash
# Get your Cloud SQL instance IP
SQL_IP=$(gcloud sql instances describe private-instance --format='value(ipAddresses[0].ipAddress)')

# Get your service account email
SERVICE_ACCOUNT=$(terraform output -raw service_account_email)

# Get your project ID
PROJECT_ID=$(gcloud config get-value project)
```

Run the Dataflow job:

```bash
gcloud dataflow flex-template run first-job \
--template-file-gcs-location gs://dataflow-templates-us-central1/latest/flex/PostgreSQL_to_BigQuery \
--region us-central1 \
--num-workers 2 \
--subnetwork regions/us-central1/subnetworks/nw1-vpc-sub1-us-central1 \
--additional-experiments use_runner_v2 \
--additional-user-labels "" \
--parameters ^~^connectionURL=jdbc:postgresql://${SQL_IP}:5432/my-database2~username=henry~password=hxi123~outputTable=${PROJECT_ID}:sample_dataset.customers~bigQueryLoadingTemporaryDirectory=gs://${PROJECT_ID}-data-bucket/temp-dir~useColumnAlias=false~isTruncate=false~partitionColumn=customer_id~partitionColumnType=long~table=public.customers~fetchSize=50000~createDisposition=CREATE_NEVER~useStorageWriteApi=false~autoscalingAlgorithm=NONE~serviceAccount=${SERVICE_ACCOUNT}~labels={\"goog-dataflow-provided-template-name\":\"postgresql_to_bigquery\"\,\"goog-dataflow-provided-template-version\":\"2025-03-11-00_rc02\"\,\"goog-dataflow-provided-template-type\":\"flex\"}
```

#### Option 2: Using GitHub Actions with Cloud Build (Best Practice)

For production environments, we recommend using GitHub Actions with Cloud Build for automated pipeline execution. This approach requires:

1. A Cloud Build service account with the following roles:
   - Cloud Build Service Account
   - Dataflow Admin
   - Service Account User
   - Cloud SQL Client
   - Storage Object Admin
   - BigQuery Data Editor

2. Setting up a GitHub repository with appropriate secrets and triggers to invoke Cloud Build

3. Creating a Cloud Build configuration file that executes the Dataflow job

This setup ensures secure, repeatable, and automated execution of your data pipeline without manual intervention.

## Infrastructure Details

### VPC Network
- Network: `nw1-vpc`
- Subnet: `nw1-vpc-sub1-us-central1` (10.10.1.0/24)
- Private Service Access connectivity for Cloud SQL

### Cloud SQL
- Primary instance: `private-instance` (us-central1)
- Read replica: `private-replica` (us-west1)
- PostgreSQL 17 with private IP connectivity
- Database: `my-database2`
- User: `henry` with password `hxi123`

### BigQuery
- Dataset: `sample_dataset`
- Tables:
  - `customers`: Target table for customer data
  - `failed_customers`: Error logging table

### Service Account
- Name: `dataflow-service-account-id`
- Roles:
  - Cloud SQL Admin
  - Secret Manager Access/Management
  - Storage Object Admin
  - Dataflow Admin/Worker
  - BigQuery Admin
  - Cloud Scheduler Admin
  - Compute Network User

## Monitoring and Maintenance

### View Dataflow Job Status
```bash
gcloud dataflow jobs list --region us-central1
```

### Check Data in BigQuery
```bash
bq query --use_legacy_sql=false 'SELECT * FROM sample_dataset.customers LIMIT 10'
```

### Cleanup
To delete all created resources:
```bash
terraform destroy -auto-approve
```

## Troubleshooting

### Common Issues

1. **Private IP connectivity**: Ensure your Dataflow job is configured to use the correct VPC subnet (`nw1-vpc-sub1-us-central1`).

2. **Permission errors**: Verify that the service account has all required permissions.

3. **Database connectivity**: Check if the PostgreSQL instance is accessible from the specified subnet.

4. **BigQuery table schema**: Ensure that the BigQuery table schema matches the source PostgreSQL table.

## Security Considerations

- Database credentials are stored in plain text in the Terraform files and Dataflow job parameters. For production environments, consider using Secret Manager.
- The PostgreSQL user has a simple password. Use stronger passwords in production.
- The VPC network is configured with relatively open internal firewall rules. Tighten these as needed.