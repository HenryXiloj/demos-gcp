# PostgreSQL CDC to BigQuery Streaming Pipeline

This project implements a real-time Change Data Capture (CDC) pipeline that streams data changes from a PostgreSQL database to BigQuery using Google Cloud Platform services.

## Architecture

The pipeline works as follows:

```
[Cloud SQL (PostgreSQL)]
   └─ (Logical replication via wal2json plugin)
        ↓
[Cloud Scheduler (runs every 12 minutes)]
   └─ Triggers →
[Cloud Run Job (custom CDC listener)]
   └─ Pulls changes using logical replication
   └─ Publishes JSON events →
[Cloud Pub/Sub Topic]
   ↓
[Dataflow (Apache Beam Flex Template)]
   ↓
[BigQuery]
```

This architecture uses Cloud Run Jobs (not continuous services) triggered by Cloud Scheduler for efficient resource usage and cost optimization.

### Components:

1. **PostgreSQL Database** - Source database with logical replication enabled using the wal2json plugin
2. **Cloud Scheduler** - Triggers the CDC listener job on a schedule (every 10 minutes)
3. **Cloud Run Jobs** - Executes the CDC listener as a job rather than a continuously running service
4. **Pub/Sub** - Message queue for decoupled event processing
5. **Dataflow** - Stream processing pipeline using Apache Beam
6. **BigQuery** - Destination for real-time analytics

## Project Structure

```
pg-cdc-to-bq-streaming/
├── pg-cdc-listener/               # Cloud Run CDC listener service
│   ├── main.py                    # PostgreSQL CDC listener implementation
│   ├── requirements.txt           # Python dependencies
│   └── Dockerfile                 # Container definition
├── pubsub_to_bq_flex_template/    # Dataflow pipeline
│   ├── main.py                    # Apache Beam pipeline implementation
│   ├── metadata.json              # Flex template metadata
│   └── requirements.txt           # Python dependencies
├── sql/                           # PostgreSQL setup scripts
│   ├── 0-init.sql                 # Replication setup (publication, slot)
│   └── 1-init_customers.sql       # Sample table and data
└── terraform/                     # Infrastructure as Code
    ├── artifact.tf                # Artifact Registry configuration
    ├── compute.tf                 # Compute and PSC configuration
    ├── dns.tf                     # Private DNS configuration
    ├── iam.tf                     # Service accounts and permissions
    ├── main.tf                    # Core resources (Cloud SQL, BigQuery)
    ├── network.tf                 # VPC networking setup
    ├── provider.tf                # Terraform provider configuration
    ├── topic.tf                   # Pub/Sub topics and subscriptions
    ├── terraform.tfvars           # Variable definitions
    └── variable.tf                # Variable declarations
```

## Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform 1.0+
- Google Cloud SDK (gcloud CLI)
- Docker (for local development)
- PostgreSQL client tools (optional, for testing)

## Setup Instructions

### 1. Infrastructure Deployment

Navigate to the terraform directory and update the `terraform.tfvars` file with your project ID:

```
project_id = "your-project-id"  # Replace with your GCP project ID
region     = "us-central1"
zone       = "us-central1-a"
sec_region = "us-west1"
sec_zone   = "us-west1-a"
private_google_access_ips = ["10.10.1.10"]
```

Deploy the infrastructure:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

This will provision:
- PostgreSQL instance with Private Service Connect (PSC)
- VPC networking with proper firewall rules
- Pub/Sub topic and subscription
- BigQuery dataset and tables
- Artifact Registry repository
- IAM service accounts and permissions

### 2. PostgreSQL Setup

#### Configure PostgreSQL Database Using Cloud SQL Studio

1. Navigate to the Cloud SQL section in the Google Cloud Console
2. Select the instance `psc-instance-test`
3. Go to Databases and select `my-database4`
4. Open Cloud SQL Studio and use the following credentials:
   * User: henry
   * Password: hxi123
5. Execute the initialization scripts:
   * Copy and paste contents from `0-init.sql` (modify user permissions if needed)
   * Copy and paste contents from `1-init_customers.sql`

Alternatively, you can navigate to the SQL tab and upload the SQL files directly.

These scripts will:
- Create the publication and replication slot
- Create a sample customers table
- Populate the table with test data
- Configure the database for logical replication

### 3. SSL Certificate Setup

Before deploying the CDC listener, you need to obtain SSL certificates for secure database connection:

1. In the Cloud SQL console, select the `psc-instance-test` instance
2. Navigate to Connections → Security → "Manage certificates"
3. Create a new client certificate by clicking "Create client certificate"
4. Download the three certificate files:
   * `server-ca.pem` (server CA certificate)
   * `client-cert.pem` (client certificate)
   * `client-key.pem` (client key)
5. Create a `certs` directory in your pg-cdc-listener folder and copy these files:

```bash
cd pg-cdc-listener
mkdir certs
# Copy the downloaded certificate files to this directory
cp ~/Downloads/server-ca.pem certs/
cp ~/Downloads/client-cert.pem certs/
cp ~/Downloads/client-key.pem certs/
```

Your Cloud Run service will use these certificates to establish an SSL connection to the PostgreSQL database.

### 4. Deploy CDC Listener as Cloud Run Job

Navigate to the pg-cdc-listener directory:

```bash
cd pg-cdc-listener

# Build and push the container
# NOTE: The Dockerfile should include steps to copy the certificates
# from the certs/ directory into the container at /certs/
gcloud builds submit --tag us-central1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo/cdc-listener-job:latest

# Create the Cloud Run Job
gcloud run jobs create cdc-listener-job \
  --image=us-central1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo/cdc-listener-job:latest \
  --region=us-central1 \
  --vpc-connector=private-cloud-sql \
  --service-account=dataflow-service-account-id@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Test execute the job manually
gcloud run jobs execute cdc-listener-job --region=us-central1

# Set up Cloud Scheduler to trigger the job every 12 minutes
gcloud scheduler jobs create http cdc-listener-job-schedule \
  --schedule "*/12 * * * *" \
  --uri "https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/YOUR_PROJECT_ID/jobs/cdc-listener-job:run" \
  --http-method POST \
  --oauth-service-account-email=dataflow-service-account-id@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --location us-central1
```

The CDC listener job will:
- Connect to PostgreSQL using logical replication
- Fetch changes that occurred since the last run
- Publish events to Pub/Sub
- Exit when complete (unlike a continuous service)

The Cloud Scheduler will trigger this job every 12 minutes, creating an efficient polling mechanism for database changes.

### 4. Deploy Dataflow Pipeline

Navigate to the pubsub_to_bq_flex_template directory:

```bash
cd pubsub_to_bq_flex_template

# Build the container image
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/pubsub-to-bq-flex

# Create the Flex Template
gcloud dataflow flex-template build gs://YOUR_PROJECT_ID-data-bucket/templates/pubsub_to_bq_flex.json \
  --image gcr.io/YOUR_PROJECT_ID/pubsub-to-bq-flex \
  --sdk-language PYTHON \
  --metadata-file metadata.json

# Run the pipeline
gcloud dataflow flex-template run "pb-to-bq-$(date +%Y%m%d-%H%M%S)" \
  --template-file-gcs-location=gs://YOUR_PROJECT_ID-data-bucket/templates/pubsub_to_bq_flex.json \
  --project=YOUR_PROJECT_ID \
  --region=us-central1 \
  --service-account-email=dataflow-service-account-id@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --parameters="\
input_topic=projects/YOUR_PROJECT_ID/topics/my_topic,\
output_table=YOUR_PROJECT_ID:sample_dataset.customers,\
failed_table=YOUR_PROJECT_ID:sample_dataset.failed_customers"
```

## Testing the Pipeline

1. Connect to your PostgreSQL database

2. Insert or update data in the customers table:
   ```sql
   INSERT INTO customers (
      customer_id, first_name, last_name, email, phone, address, registration_date, loyalty_points
      ) VALUES (
      2031, 'Test', 'User', 'test123456731@example.com', '5558881234', '456 Beam Street', CURRENT_DATE, 100
      );

   ```

3. Check BigQuery to see the changes propagated:
   ```bash
     SELECT * FROM YOUR_PROJECT_ID.sample_dataset.customers'
   ```

## Troubleshooting

### Common Issues

1. **SSL Certificate Problems**

   If you encounter SSL certificate issues:
   - Verify the certificates are correctly placed in the `/certs/` directory in your Docker container
   - Check certificate permissions (they should be readable by the application)
   - Ensure the certificates haven't expired
   - Confirm you're using the correct certificate files for your Cloud SQL instance

2. **Replication Slot Issues**
   
   If the slot is not working properly, check its status in Cloud SQL Studio:
   ```sql
   SELECT * FROM pg_replication_slots WHERE slot_name = 'my_slot';
   ```
   
   You might need to drop and recreate it:
   ```sql
   SELECT pg_drop_replication_slot('my_slot');
   SELECT pg_create_logical_replication_slot('my_slot', 'wal2json');
   ```

3. **Database Connectivity Issues**
   
   If the CDC listener can't connect to the database:
   - Check Private Service Connect configurations
   - Verify VPC connector is properly set up
   - Ensure the database user has REPLICATION privileges
   - Test basic connectivity with a simple query
   - Check DNS resolution for the database hostname

4. **Cloud Run Connectivity Issues**
   
   Check the Cloud Run service logs:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=python-cloudsql-run" --limit 50
   ```

5. **Dataflow Pipeline Issues**
   
   Check the Dataflow job logs in the Google Cloud Console or via:
   ```bash
   gcloud dataflow jobs describe JOB_ID
   ```

### Monitoring

- Monitor Pub/Sub message throughput in Cloud Monitoring
- Check Cloud Run container logs for CDC listener status
- Use Dataflow monitoring to track pipeline performance

## Security Considerations

- The PostgreSQL instance is configured with Private Service Connect (PSC)
- SSL is required for database connections
- Service accounts use principle of least privilege
- All internal communication occurs within the VPC

## Cleanup

To avoid incurring charges, delete the resources when no longer needed:

```bash
cd terraform
terraform destroy -auto-approve
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
