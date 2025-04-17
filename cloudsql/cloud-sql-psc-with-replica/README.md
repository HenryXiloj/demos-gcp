# Terraform Configuration for Cloud SQL with Private Service Connect (PSC)

This repository contains Terraform configurations to deploy a PostgreSQL database on Google Cloud SQL with Private Service Connect (PSC) connectivity. The setup includes a primary instance in `us-central1` region and a read replica in `us-west1`.

## Overview

The configuration creates:

1. A PostgreSQL 17 Cloud SQL instance with Private Service Connect enabled
2. A read replica in a secondary region for high availability
3. Custom VPC network with appropriate subnets and firewall rules
4. Service account with necessary IAM permissions
5. VPC peering connection to enable private access

## Prerequisites

- Terraform v1.0.0+
- Google Cloud Platform account with appropriate permissions
- `gcloud` CLI configured with access to your project

## Project Structure

```
├── iam.tf                # Service account and IAM permissions
├── main.tf               # Cloud SQL instance configuration
├── network.tf            # VPC, subnet, and firewall rules
├── provider.tf           # Provider configuration
├── terraform.tfvars      # Variables configuration
├── variable.tf           # Variable definitions
└── README.md             # Project documentation
```

## Deployment Instructions

1. Clone this repository
2. Update the `terraform.tfvars` file with your project details
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Review the planned changes:
   ```
   terraform plan
   ```
5. Apply the configuration:
   ```
   terraform apply
   ```

## Cloud SQL Configuration Details

### Primary Instance
- Name: `psc-instance-test`
- Region: `us-central1`
- Database Version: PostgreSQL 17
- Machine Type: `db-perf-optimized-N-2`
- Edition: Enterprise Plus
- Availability: Regional (high availability)
- IAM Authentication: Enabled
- PSC Enabled: Yes
- SSL Mode: Trusted Client Certificate Required

### Read Replica
- Name: `psc-instance-test-replica`
- Region: `us-west1`
- Same configuration as primary
- Labels:
  - environment: test
  - type: read-replica
  - role: analytics

## Network Configuration

The setup creates:
- VPC: `nw1-vpc`
- Subnet: `nw1-vpc-sub1-[REGION]` with CIDR `10.10.1.0/24`
- Firewall rules for internal traffic and PostgreSQL access
- VPC peering with Google services for private connectivity

## Security Features

- Private Service Connect (PSC) for secure connectivity
- IAM authentication enabled
- SSL certificate validation required
- No public IP addresses exposed
- Service account with least privilege

## Important Notes

- **PostgreSQL Version**: By default from PostgreSQL 16, the edition is ENTERPRISE_PLUS. For available machine types, check the [Cloud SQL machine series documentation](https://cloud.google.com/sql/docs/postgres/machine-series-overview).

- **Version Upgrade Process**: To upgrade to the latest PostgreSQL version (e.g., PostgreSQL 17):
  1. **Remove the replica first**:
     - Comment out the `google_sql_database_instance.psc_instance_replica` resource
     - Run `terraform apply` to remove the replica
  2. **Upgrade the primary instance**:
     - Update the `database_version` in the primary instance to the new version
     - Run `terraform apply` to upgrade the primary
  3. **Recreate the replica**:
     - Uncomment the replica resource and update its `database_version`
     - Run `terraform apply` to create the new replica
  
  This process ensures that the DNS entry for the primary is maintained during the upgrade.

## Service Account

A dedicated service account is created with the following roles:
- Cloud SQL Admin
- Secret Manager Secret Accessor
- Secret Manager Secret Version Manager


## References

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect)
- [Cloud SQL Machine Types](https://cloud.google.com/sql/docs/postgres/machine-series-overview)