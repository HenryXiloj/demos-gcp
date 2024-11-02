# Terraform Google Cloud Dataproc Project

This repository contains Terraform configurations for deploying and managing a Google Cloud Dataproc cluster along with associated resources including BigQuery datasets, Cloud Storage buckets, networking components, and various types of Dataproc jobs.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or higher)
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
- Enables required Google Cloud APIs
- Creates service account for Dataproc cluster
- Assigns necessary IAM roles

### 2. Networking (network.tf)
- Creates VPC network with custom subnet
- Configures Cloud NAT for internet access
- Sets up firewall rules for:
  - Internal traffic
  - SSH via Identity-Aware Proxy (IAP)
  - Egress internet access

### 3. Storage (bucket.tf)
- Creates storage buckets for:
  - Dataproc staging
  - ETL scripts and resources
- Uploads required scripts and data files

### 4. BigQuery (bigquery.tf)
- Creates dataset and tables
- Configures data loading jobs
- Manages table schemas

### 5. Dataproc (dataproc.tf)
- Deploys a Dataproc cluster with:
  - 1 master node (n2-standard-4)
  - 2 worker nodes (n2-standard-4)
  - Custom initialization actions
  - Network isolation

### 6. Jobs (jobs.tf)
Configures various types of Dataproc jobs:
- PySpark jobs
- Spark jobs
- Hadoop jobs
- Hive jobs
- Pig jobs
- SparkSQL jobs

## Variables

Key variables defined in `variables.tf` and set in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| project_id | Google Cloud Project ID | - |
| project_number | Google Cloud Project Number | - |
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

5. To destroy resources:
```bash
terraform destroy
```

## Important Notes

- The Dataproc cluster is configured with internal IP only
- All resources are deployed in a private VPC
- Cloud NAT is configured for internet access
- The project uses uniform bucket-level access for Cloud Storage
- BigQuery tables have deletion protection disabled (for development purposes)

## Security Considerations

- All resources are deployed in a private VPC
- SSH access is only available through IAP
- Service accounts have minimum required permissions
- Internal-only IP addresses are used where possible

## Resource Dependencies

The deployment follows this dependency order:
1. APIs and IAM configurations
2. Networking components
3. Storage buckets
4. BigQuery resources
5. Dataproc cluster
6. Dataproc jobs

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

[Specify your license here]
