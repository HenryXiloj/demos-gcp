# Terraform Google Cloud Dataproc Project

This repository contains Terraform configurations for deploying and managing a Google Cloud Dataproc cluster along with associated resources including BigQuery datasets, Cloud Storage buckets, networking components, and various types of Dataproc jobs.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.9.8 or higher)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- A Google Cloud Project with billing enabled
- Appropriate IAM permissions to create and manage resources

## Project Structure

```
.
├── README.md
├── provider.tf        # Provider configuration
├── variables.tf       # Variable definitions
├── terraform.tfvars   # Variable values
├── iam.tf            # IAM and API configurations
├── network.tf        # VPC and networking resources
├── bucket.tf         # Cloud Storage configurations
├── bigquery.tf       # BigQuery datasets and tables
├── dataproc.tf       # Dataproc cluster configuration
└── jobs.tf           # Dataproc job definitions
```

## Resource Components

### 1. IAM and API Configuration (iam.tf)
- Enables required Google Cloud APIs:
  - dataproc.googleapis.com
  - compute.googleapis.com
- Creates service account for Dataproc cluster
- Assigns necessary IAM roles including:
  - dataproc.admin
  - dataproc.worker
  - storage.objectAdmin
  - bigquery.admin
  - and more

### 2. Networking (network.tf)
- Creates VPC network with custom subnet
- Configures Cloud NAT for internet access
- Sets up firewall rules for:
  - Internal traffic (TCP/UDP ports 0-65535)
  - SSH via Identity-Aware Proxy (IAP)
  - Egress internet access (ports 80, 443)

### 3. Storage (bucket.tf)
- Creates storage buckets for:
  - Dataproc staging (`dataproc-staging-${project_id}`)
  - ETL scripts (`etl-scripts-${project_id}`)
- Uploads required scripts:
  - bq_compare_insert.py
  - spark_random_numbers.py
  - table1_data.csv
  - startup_script.sh

### 4. BigQuery (bigquery.tf)
- Creates dataset: `example_dataset`
- Creates tables:
  - table1
  - table2
  - table3
- Configures data loading jobs with CSV import
- Manages table schemas with id, name, and age fields

### 5. Dataproc (dataproc.tf)
Deploys a Dataproc cluster with:
- Master node:
  - 1x n2-standard-4
  - 1024GB boot disk
- Worker nodes:
  - 2x n2-standard-4
  - 1024GB boot disk each
- Image version: 2.2-debian12
- Optional components: JUPYTER
- Network isolation (internal IP only)
- Custom initialization actions

### 6. Jobs (jobs.tf)
Configures various types of Dataproc jobs:
- PySpark jobs:
  - BigQuery comparison job
  - Random numbers generation
- Spark jobs (SparkPi example)
- Hadoop jobs (WordCount example)
- Hive jobs (Table creation and querying)
- Pig jobs (Word counting from LICENSE.txt)
- SparkSQL jobs (Table operations)

## Variables

Key variables defined in `variables.tf` and set in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| project_id | Google Cloud Project ID | MY-PROJECT-ID |
| project_number | Google Cloud Project Number | MY-PROJECT-NUMBER |
| region | Primary region for resources | us-central1 |
| zone | Primary zone for resources | us-central1-a |
| sec_region | Secondary region | us-west1 |
| sec_zone | Secondary zone | us-west1-a |

## Usage

1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. Before destroying resources:

   a. Install the BigQuery command-line tool:
   ```bash
   gcloud components install bq
   ```

   b. Check the BigQuery job details:
   ```bash
   bq show --project_id=<MY-PROJECT-ID> --location=<MY-LOCATION> -j load-table1-job1
   ```

   c. Remove the BigQuery job:
   ```bash
   bq rm -j --location=<MY-LOCATION> --project_id=<MY-PROJECT-ID> load-table1-job1
   ```

   Note: BigQuery jobs must be manually cleaned up before destroying the infrastructure as they are not automatically removed by Terraform.

6. Destroy the infrastructure:
```bash
terraform destroy
```

## Important Notes

- The Dataproc cluster is configured with internal IP only
- All resources are deployed in a private VPC
- Cloud NAT is configured for internet access
- The project uses uniform bucket-level access for Cloud Storage
- BigQuery tables have deletion protection disabled (for development purposes)
- Custom initialization scripts are executed during cluster creation
- All data transfer between components occurs within the private network

## Security Considerations

- All resources are deployed in a private VPC
- SSH access is only available through IAP (35.235.240.0/20)
- Service accounts have minimum required permissions
- Internal-only IP addresses are used where possible
- Uniform bucket-level access enforced on all storage buckets
- Firewall rules are configured with principle of least privilege

## Resource Dependencies

The deployment follows this dependency order:
1. APIs and IAM configurations
2. Networking components (VPC, subnet, firewall rules)
3. Storage buckets and initial data upload
4. BigQuery resources (dataset and tables)
5. Dataproc cluster creation
6. Dataproc jobs configuration

## Troubleshooting

Common issues and solutions:

1. BigQuery Job Deletion:
   - Error: Cannot destroy resources due to existing BigQuery jobs
   - Solution: Use the bq command-line tool to remove jobs manually

2. Networking:
   - Issue: Dataproc cluster cannot access internet
   - Solution: Verify Cloud NAT configuration and firewall rules

3. Permission Issues:
   - Problem: Insufficient permissions for service account
   - Solution: Verify IAM roles are correctly assigned

## Acknowledgments

- Google Cloud Platform Documentation
- Terraform Documentation
- Apache Spark Documentation

---

For more information about specific components, please refer to:
- [Google Cloud Dataproc Documentation](https://cloud.google.com/dataproc/docs)
- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
