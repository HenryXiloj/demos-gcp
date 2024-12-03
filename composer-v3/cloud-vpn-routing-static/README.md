# Terraform Project

This repository contains Terraform configurations for provisioning and managing infrastructure.

## Projects Overview

### 1st-cloud-sql-psc-vm-composer-v3
This repository includes:
- **Google Cloud Composer v3**
- **Cloud SQL Private Service Connect (PSC)**
- **VM instances**
- **DNS Peering**
- **Cloud VPN (Static Routing)**

Additionally, the `resources` folder contains the following scripts:
- `check_worker_ip_dag.py`: Checks IP resolution using `nslookup` and `telnet` please chage `<DNS_NAME>` into py script before run, you can find `<DNS_NAME>` Cloud SQL PSC instance.
- `cloud_sql_connector_psc_dag.py`: Connects to a Cloud SQL PSC instance in the same project via the Cloud SQL connector.
- `cloud_sql_connector_psc_dag2.py`: Connects to a Cloud SQL PSC instance in a remote project using DNS peering and Cloud VPN static routes.

### 2nd-cloud-sql-psc-vm
This repository includes:
- **Cloud SQL Private Service Connect (PSC)**
- **VM instances**
- **Cloud VPN (Static Routing)**

This configuration focuses on connecting Composer-v3/VMs with remote cloud SQL PSC.

---

## Usage

### Prerequisites
1. **Install Terraform**  
   Ensure Terraform is installed on your system. Download it from [Terraform's official website](https://www.terraform.io/downloads.html).

2. **Modify `terraform.tfvars`**
   Update the following variables before running Terraform:

#### 1st-cloud-sql-psc-vm-composer-v3
```hcl
project_id     = "<PROJECT_ID>"
project_number = "<PROJECT_NUMBER>"
project_id_2   = "<2ND_PROJECT_ID>"
```
#### 2nd-cloud-sql-psc-vm
```hcl
project_id     = "<PROJECT_ID>"
```

### First Run

#### Cloud VPN Setup
Comment out the Cloud VPN configurations initially. External IP addresses are required for VPN tunnel creation in both projects.
1. **[cloud-vpn.tf](./1st-cloud-sql-psc-vm-composer-v3/cloud-vpn.tf)** 
2. **[cloud-vpn.tf](./2nd-cloud-sql-psc-vm/cloud-vpn.tf)**  

#### Run Terraform Commands
Initialize and apply Terraform configurations for each project:

1. **Initialize the Terraform Project**  
   Run the following command to initialize the project and download the necessary provider plugins:
   ```bash
   terraform init
   ```

2. **Review the Plan**  
   Preview the changes that will be applied to your infrastructure:
   ```bash
   terraform plan
   ```
3. **Apply the Configuration**  
   Apply the changes to create or update the resources:
   ```bash
   terraform apply
   ```

### Second Run

### Enable Cloud VPN
Uncomment the Cloud VPN configurations (`cloud-vpn.tf`) in both projects.
1. **[cloud-vpn.tf](./1st-cloud-sql-psc-vm-composer-v3/cloud-vpn.tf)** 
2. **[cloud-vpn.tf](./2nd-cloud-sql-psc-vm/cloud-vpn.tf)**  

### Update `terraform.tfvars`

#### For `1st-cloud-sql-psc-vm-composer-v3`:
```text
static_peer_second_GCP_project_IP = "<EXTERNAL_IP_ADDRESS_OF_SECOND_PROJECT>"
```

### For `2nd-cloud-sql-psc-vm`:
```text
static_peer_first_GCP_project_IP = "<EXTERNAL_IP_ADDRESS_OF_FIRST_PROJECT>"
```

### Additional Updates
If subnet ranges are changed, update these variables:

- `static_peer_second_GCP_project_IP` in `1st-cloud-sql-psc-vm-composer-v3`
- `destination_range_in_peer_first_GCP_project` in `2nd-cloud-sql-psc-vm`

#### Run Terraform Commands
Initialize and apply Terraform configurations for each project:

1. **Initialize the Terraform Project**  
   Run the following command to initialize the project and download the necessary provider plugins:
   ```bash
   terraform init
   ```

2. **Review the Plan**  
   Preview the changes that will be applied to your infrastructure:
   ```bash
   terraform plan
   ```
3. **Apply the Configuration**  
   Apply the changes to create or update the resources:
   ```bash
   terraform apply
   ```

### Overview

## 1st-cloud-sql-psc-vm-composer-v3

1. **[composer.tf](./1st-cloud-sql-psc-vm-composer-v3/composer.tf)**  
   Configurations for Google Cloud Composer environment setup, including resource definitions and dependencies.

2. **[compute.tf](./1st-cloud-sql-psc-vm-composer-v3/compute.tf)**  
   Contains definitions for compute resources, such as virtual machine instances, disk configurations, and related metadata.

3. **[dns.tf](./1st-cloud-sql-psc-vm-composer-v3/dns.tf)**  
   Manages DNS configurations, including zones, records, and related networking setup.

4. **[iam.tf](./1st-cloud-sql-psc-vm-composer-v3/iam.tf)**  
   IAM policy and role assignments for managing permissions and access control across resources.

5. **[main.tf](./1st-cloud-sql-psc-vm-composer-v3/main.tf)**  
   The main Terraform configuration file that ties together all other resource modules and definitions.

6. **[network.tf](./1st-cloud-sql-psc-vm-composer-v3/network.tf)**  
   Networking configurations, such as VPCs, subnets, firewalls, and other network-related resources.

7. **[provider.tf](./1st-cloud-sql-psc-vm-composer-v3/provider.tf)**  
   Specifies the provider configurations (e.g., Google Cloud provider) and authentication settings required for Terraform.

8. **[terraform.tfvars](./1st-cloud-sql-psc-vm-composer-v3/terraform.tfvars)**  
   Variables file containing environment-specific values, such as project IDs, regions, and resource names.

9. **[variable.tf](./1st-cloud-sql-psc-vm-composer-v3/variable.tf)**  
   Definitions for variables used across the Terraform configuration files.


## 2nd-cloud-sql-psc-vm

1. **[compute.tf](./2nd-cloud-sql-psc-vm/compute.tf)**  
   Contains definitions for compute resources, such as virtual machine instances, disk configurations, and related metadata.

2. **[dns.tf](./2nd-cloud-sql-psc-vm/dns.tf)**  
   Manages DNS configurations, including zones, records, and related networking setup.

3. **[iam.tf](./2nd-cloud-sql-psc-vm/iam.tf)**  
   IAM policy and role assignments for managing permissions and access control across resources.

4. **[main.tf](./2nd-cloud-sql-psc-vm/main.tf)**  
   The main Terraform configuration file that ties together all other resource modules and definitions.

5. **[network.tf](./2nd-cloud-sql-psc-vm/network.tf)**  
   Networking configurations, such as VPCs, subnets, firewalls, and other network-related resources.

6. **[provider.tf](./2nd-cloud-sql-psc-vm/provider.tf)**  
   Specifies the provider configurations (e.g., Google Cloud provider) and authentication settings required for Terraform.

7. **[terraform.tfvars](./2nd-cloud-sql-psc-vm/terraform.tfvars)**  
   Variables file containing environment-specific values, such as project IDs, regions, and resource names.

8. **[variable.tf](./2nd-cloud-sql-psc-vm/variable.tf)**  
   Definitions for variables used across the Terraform configuration files.



   