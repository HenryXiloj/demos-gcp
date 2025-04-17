# Terraform Configuration for Cloud SQL with Private Service Access (PSA)

This repository contains Terraform configurations to deploy a PostgreSQL database on Google Cloud SQL with Private Service Access (PSA). The setup includes a primary instance in `us-central1` region and a read replica in `us-west1` with private IP connectivity.

## Overview

The configuration creates:

1. A PostgreSQL 17 Cloud SQL instance with Private Service Access (no public IP)
2. A read replica in a secondary region for high availability and disaster recovery
3. Custom VPC network with appropriate subnets and firewall rules
4. Service account with necessary IAM permissions
5. VPC peering connection with Google service networking

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
- Name: `private-instance`
- Region: `us-central1`
- Database Version: PostgreSQL 17
- Machine Type: `db-perf-optimized-N-2`
- Edition: Enterprise Plus
- Private IP only: Yes (no public IP address)
- Private Google Access: Enabled

### Read Replica
- Name: `private-replica`
- Region: `us-west1`
- Same configuration as primary
- Connects to primary through private network

## Network Configuration

The setup creates:
- VPC: `nw1-vpc`
- Subnet: `nw1-vpc-sub1-[REGION]` with CIDR `10.10.1.0/24`
- Firewall rules for:
  - Internal traffic within the VPC
  - PostgreSQL access (ports 5432, 3307, 3306)
  - SQL proxy egress traffic
- VPC peering with Google services to enable Private Service Access

## Security Features

- Private Service Access (PSA) for secure connectivity
- No public IP addresses exposed
- VPC network isolation
- Service account with least privilege
- Private Google access enabled for Google Cloud services

## Important Notes

- **PostgreSQL Version**: By default from PostgreSQL 16, the edition is ENTERPRISE_PLUS. For available machine types, check the [Cloud SQL machine series documentation](https://cloud.google.com/sql/docs/postgres/machine-series-overview).

- **Version Upgrade Process**: To upgrade to the latest PostgreSQL version (e.g., PostgreSQL 17):
  1. **Remove the replica first**:
     - Comment out the `google_sql_database_instance.my_private_replica` resource
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

## Difference Between PSA and PSC

This configuration uses Private Service Access (PSA), which:
- Creates a VPC peering connection with Google's service producer network
- Assigns private IP addresses from your allocated range
- Requires the `enable_private_path_for_google_cloud_services` parameter for Google service access

The PSC (Private Service Connect) approach in another configuration:
- Uses PSC endpoints as connection points
- Provides more granular access control
- Uses the `psc_enabled` parameter instead of private networking

## References

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Private Service Access](https://cloud.google.com/vpc/docs/private-services-access)
- [Cloud SQL Auth Proxy](https://cloud.google.com/sql/docs/postgres/connect-admin-proxy)
- [Cloud SQL Machine Types](https://cloud.google.com/sql/docs/postgres/machine-series-overview)