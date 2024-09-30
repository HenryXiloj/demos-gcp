# Terraform GCP Infrastructure

This project uses Terraform to set up Google Cloud Platform (GCP) infrastructure, including VPC networks, subnets, firewalls, Cloud SQL, and more.

## Project Structure

- `main.tf`: Contains the main infrastructure configurations, including Cloud SQL instance setup.
- `network.tf`: Defines VPC networks, subnets, firewalls, and other network-related resources.
- `provider.tf`: Specifies the required providers and their versions.
- `variable.tf`: Declares variables used across the Terraform configurations.
- `terraform.tfvars`: Sets values for the declared variables.
- `serviceaccount.tf`: Creates a service account for Cloud SQL.
- `compute.tf`: Configures compute resources like internal IP addresses.
- `artifact.tf`: Sets up an Artifact Registry repository.
- `iam.tf`: Manages IAM roles and permissions.

## Prerequisites

- Terraform installed (version compatible with provider requirements)
- Google Cloud SDK installed and configured
- GCP project created and billing enabled

## Getting Started

1. Clone this repository.
2. Update `terraform.tfvars` with your specific project details:

   ```hcl
   project_id = "<YOUR-PROJECT-ID>"
   region     = "us-central1"
   zone       = "us-central1-a"
   sec_region = "us-west1"
   sec_zone   = "us-west1-a"
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Review the planned changes:

   ```bash
   terraform plan
   ```

5. Apply the configuration:

   ```bash
   terraform apply
   ```

## Key Components

- **VPC Network**: Creates a custom VPC named "nw1-vpc" with two subnets.
- **Firewalls**: Sets up firewall rules for SSH, internal communication, and IAP access.
- **NAT Gateway**: Configures a NAT gateway for outbound internet access from private instances.
- **Private Service Connect**: Enables private connectivity for services like Cloud SQL.
- **Cloud SQL**: Creates a PostgreSQL instance with Private Service Connect enabled.
- **Artifact Registry**: Sets up a Docker repository.
- **IAM**: Configures necessary IAM roles for the Cloud SQL service account.

## Notes

- The Cloud SQL instance is set up with Private Service Connect (PSC) for enhanced security.
- Deletion protection is disabled for the Cloud SQL instance in this configuration. Enable it for production use.
- The project uses a service account for Cloud SQL operations. Ensure proper IAM roles are assigned.

## Customization

- Modify `variable.tf` and `terraform.tfvars` to adjust project-specific settings.
- Update `network.tf` to change network configurations like IP ranges or add more subnets.
- Adjust `iam.tf` to add or remove IAM roles as needed for your project.

## Security Considerations

- Review and adjust firewall rules in `network.tf` to match your security requirements.
- Consider enabling additional security features for Cloud SQL in production environments.
- Ensure that sensitive information like passwords is managed securely, preferably using secret management solutions.

## Maintenance

Regularly update your Terraform configurations and provider versions to ensure you're using the latest features and security updates.