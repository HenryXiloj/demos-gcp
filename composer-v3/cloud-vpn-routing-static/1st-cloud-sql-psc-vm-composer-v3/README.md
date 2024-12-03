# Terraform Project

This repository contains Terraform configurations for provisioning and managing infrastructure. Below is a description of each file and its purpose.

## Files

1. **[composer.tf](./composer.tf)**  
   Configurations for Google Cloud Composer environment setup, including resource definitions and dependencies.

2. **[compute.tf](./compute.tf)**  
   Contains definitions for compute resources, such as virtual machine instances, disk configurations, and related metadata.

3. **[dns.tf](./dns.tf)**  
   Manages DNS configurations, including zones, records, and related networking setup.

4. **[iam.tf](./iam.tf)**  
   IAM policy and role assignments for managing permissions and access control across resources.

5. **[main.tf](./main.tf)**  
   The main Terraform configuration file that ties together all other resource modules and definitions.

6. **[network.tf](./network.tf)**  
   Networking configurations, such as VPCs, subnets, firewalls, and other network-related resources.

7. **[provider.tf](./provider.tf)**  
   Specifies the provider configurations (e.g., Google Cloud provider) and authentication settings required for Terraform.

8. **[terraform.tfvars](./terraform.tfvars)**  
   Variables file containing environment-specific values, such as project IDs, regions, and resource names.

9. **[variable.tf](./variable.tf)**  
   Definitions for variables used across the Terraform configuration files.

## Usage

1. **Install Terraform**  
   Ensure Terraform is installed on your system. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).

2. **Initialize the Terraform Project**  
   Run the following command to initialize the project and download the necessary provider plugins:
   ```bash
   terraform init
   ```

3. **Review the Plan**  
   Preview the changes that will be applied to your infrastructure:
   ```bash
   terraform plan
   ```
4. **Apply the Configuration**  
   Apply the changes to create or update the resources:
   ```bash
   terraform apply
   ```
5. **Destroy the Infrastructure (Optional)**  
   Apply the changes to create or update the resources:
   ```bash
   terraform destroy
   ```