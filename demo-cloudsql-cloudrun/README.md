# Cloud SQL Terraform and Spring Boot App

This repository contains 4 projects:

1. **cloud-sql**: Terraform configuration to set up a Cloud SQL instance with Private Service Connect.
2. **demoWIF**: Terraform project for Workload Identity Federation (WIF) Open Id Connect
3. **demo-cloudsql-cloudrun**: A Spring Boot application that connects to the Cloud SQL instance and runs on Cloud Run.
4. **frameworks-coren**: A Maven application Dummy Framework

## Enabled APIs

The following APIs need to be enabled for this project:

- Cloud Functions API
- Cloud SQL API
- Cloud Run API
- Cloud Build API
- Artifact Registry API
- Eventarc API
- Compute Engine API
- Service Networking API
- Cloud Logging API
- Workflows Serverless API
- Serverless VPC Access API

## Versions

- Terraform Provider: 5.18.0
- Spring Boot: 3.2.3 with Java 17
- PostgreSQL: 15

## Notes

- Change the GCP project name in the `terraform.tfvars` file for the Terraform project.
- Change the GCP project name in the `application.yml` file for the Spring Boot App.

## GCP Project Name

terraform-workspace-413615

## Usage

### cloud-sql folder

1. Run the following commands:

```bash
terraform init
terraform validate
terraform apply -auto-approve
```

### Local Console

2. Run Gloud commands for Private Service Connect:
- `gcloud sql instances describe psc-instance --project MY_PROJECT_ID`
    - 2.1 Search for `pscServiceAttachmentLink`
    - 2.2 Search for `dnsName`

3. Run these commands in console (Note: networks and others values come from network.tf and compute.tf via terraform)

```bash
gcloud compute forwarding-rules create psc-service-attachment-link \
  --address=internal-address \
  --project=MY_PROJECT_ID \
  --region=us-central1 \
  --network=nw1-vpc \
  --target-service-attachment=SERVICE_ATTACHMENT_URI(this value come from 2.1)

gcloud dns managed-zones create cloud-sql-dns-zone \
  --project=MY_PROJECT_ID \
  --description="DNS zone for the Cloud SQL instance" \
  --dns-name=DNS_NAME (this value come from 2.2) \
  --networks=nw1-vpc \
  --visibility=private 

gcloud dns record-sets create DNS_NAME (this value come from 2.2) \
 --project=MY_PROJECT_ID \
 --type=A \
 --rrdatas=10.10.1.10 \
 --zone=cloud-sql-dns-zone  
```
4. gcloud commands for create Artifacts Repositories \
   4.1 Artifact Repository Docker for Cloud Run
```bash
 gcloud artifacts repositories create my-repo --location us-central1 --repository-format docker
```
4.2 Artifact Repository Maven for Dummy Framework
 ```bash
 gcloud artifacts repositories create tf-repo --location us-central1 --repository-format maven
```



### Frameworks-core Project
5. Push Dummy Framework in tf-repo \
   Run:
```bash
   mvn clean install 
   mvn deploy 
```

### Spring Boot App Project
6. After modifying `MY_PROJECT_ID` in `application.yml` on Spring Boot App, run:

```bash
 mvn clean install
```

### Local Console

7. Docker Commands via console:
```bash
 docker build -t quickstart-springboot:1.0.1 .

 docker tag quickstart-springboot:1.0.1 us-central1-docker.pkg.dev/MY_PROJECT_ID/my-repo/quickstart-springboot:1.0.1

 docker push us-central1-docker.pkg.dev/MY_PROJECT_ID/my-repo/quickstart-springboot:1.0.1
```

8.  Create Cloud Run with name `springboot-run-psc` or `any-name`:
```bash
 gcloud run deploy springboot-run-psc \
   --image us-central1-docker.pkg.dev/MY_PROJECT_ID/my-repo/quickstart-springboot:1.0.1 \
   --region=us-central1 \
   --allow-unauthenticated \
   --service-account=cloudsql-service-account-id@terraform-workspace-413615.iam.gserviceaccount.com \
   --vpc-connector private-cloud-sql
```

9. Updating worflows in resource folder Spring boot app
 ```bash
 gcloud workflows deploy batch1-workflow --source=workflow1.yaml --service-account=cloudsql-service-account-id@terraform-workspace-413615.iam.gserviceaccount.com
```

### Compute Engine VM instances
1. Firewall rule in compute.tf `allow-ssh-from-cloud-run`
2. Copy Internal IP from GCP Console
   ![alt text](https://github.com/HenryXiloj/demo-cloudsql-cloudrun/blob/main/internalIP.png?raw=true)

4. Open SSH 
![alt text](https://github.com/HenryXiloj/demo-cloudsql-cloudrun/blob/main/ssh.png?raw=true)

5. Enable Password Authentication on the Server: Edit the SSH server configuration file on your Compute Engine VM instance. The location of the SSH server configuration file may vary depending on the Linux distribution, but it's commonly located at `/etc/ssh/sshd_config`.

Open the configuration file in a text editor, for example:

```bash
 sudo nano /etc/ssh/sshd_config
```
Find the line containing `PasswordAuthentication` and change its value to `yes`:
```bash
 PasswordAuthentication yes
```

5. Restart SSH Service: After making changes to the SSH server configuration, you need to restart the SSH service for the changes to take effect. Run the following command:
```bash
 sudo service ssh restart
```
Alternatively, on some systems, you may need to use the systemctl command:
```bash
 sudo systemctl restart sshd
```
6. Switch to Root User (Optional): If you're not already logged in as the root user or a user with sudo privileges, switch to the root user using the following command:
```bash
 sudo su -
```
7. Create a New User: Use the adduser command to create a new user. Replace `<username>` with the desired username for the new user.
```bash
 adduser <username>
```
8. Set a Password for the New User: After creating the user, set a password for the new user using the passwd command. You'll be prompted to enter and confirm the password.
```bash
 passwd <username>
```
9. Grant Sudo Privileges (Optional): If you want to grant sudo privileges to the new user (allowing them to execute commands with elevated privileges), you can add the user to the `sudo` group.
```bash
 usermod -aG sudo <username>
```
10. Test the New User: Disconnect from the VM instance and reconnect using the credentials of the new user to ensure that the user account was created successfully and is functioning as expected.

### Workload Identity Federation (WIF)
### demoWIF folder

1. Run the following commands:

```bash
terraform init
terraform validate
terraform apply -auto-approve
```

2. Possible issues:
    - Error `409` mean  `pool_id` exist, please change name in `module "gh_oidc"` why happen this error below
    - You can undelete a pool for up to 30 days after deletion. After 30 days, deletion is permanent. Until a pool is permanently deleted, you cannot reuse its name when creating a new workload identity pool.
    - Refer to [this link](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#delete-provider)

3. Run this command Refer to [this link](https://github.com/google-github-actions/deploy-appengine/issues/247):
```bash
#gcloud iam service-accounts add-iam-policy-binding gcp-github-access@terraform-workspace-413615.iam.gserviceaccount.com --project=terraform-workspace-413615 --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/612251736587/locations/global/workloadIdentityPools/gh-identity-pool1/attribute.repository/HenryXiloj/cloud-sql-run-github-actions"
gcloud iam service-accounts add-iam-policy-binding <MY-SERVICE-ACCOUNT> --project=<MY-PROJECT> --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/<MY-PROJECT-NUMBER>/locations/global/workloadIdentityPools/<MY-POOL-ID>/attribute.repository/<MY-USER-OR-COMPANY>/<MY-REPO-NAME>"
```

4. .github/workflows/*.yml
    - Update ENV according `pool_id` if you change `pool_id` name or others values.


## Destroy

### Console Commands

1. Run these commands in console:

```bash
 gcloud dns record-sets delete DNS_NAME(this value come from 2.2) --type=A --zone=cloud-sql-dns-zone

 gcloud dns managed-zones delete cloud-sql-dns-zone --project=MY_PROJECT_ID

 gcloud compute forwarding-rules delete psc-service-attachment-link --region=us-central1 --project=MY_PROJECT_ID

 gcloud artifacts repositories delete my-repo --location=us-central1

 gcloud artifacts repositories delete tf-repo --location=us-central1

 gcloud run services delete springboot-cloudsql-run --region us-central1
```

### Terraform

1. Run cloud-sql folder:

```bash
 terraform destroy -auto-approve
```


2. Note: With Terraform provider 5.18.0, there's an issue. Refer to [this link](https://github.com/hashicorp/terraform-provider-google/issues/16275).
- Remove manually in GCP console:
    - Go To: VPC network peering
    - And delete: `servicenetworking-googleapis-com`

3. Then, run:
```bash
 terraform destroy -auto-approve
```

4. Run demoWIF folder:

```bash
 terraform destroy -auto-approve
```

### Diagram
![alt text](https://github.com/HenryXiloj/demo-cloudsql-cloudrun/blob/main/option1.png?raw=true)







### References
 -    https://cloud.google.com/sql/docs/postgres/configure-private-service-connect#connect-using-language-connectors
 -    https://cloud.google.com/sql/docs/postgres/configure-private-service-connect#connect-from-applications
 -    https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory/blob/main/docs/jdbc.md
 -    https://cloud.google.com/sql/docs/postgres/configure-private-service-connect
 -    https://cloud.google.com/sql/docs/postgres/configure-private-service-connect#create-psc-endpoint
 -    https://cloud.google.com/sql/docs/postgres/connect-overview
 -    https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#console
 -    https://cloud.google.com/vpc/docs/serverless-vpc-access
 -    https://cloud.google.com/sql/docs/postgres/connect-run#java_2
 -    https://cloud.google.com/run/docs/configuring/connecting-vpc
 -    https://cloud.google.com/sql/docs/postgres/connect-instance-cloud-functions
 -    https://github.com/GoogleCloudPlatform/serverless-expeditions/tree/main/cloud-run-cloud-sql
 -    https://xebia.com/blog/how-to-create-a-private-serverless-connection-with-cloudsql/
 -    https://googlecloudplatform.github.io/spring-cloud-gcp/reference/html/index.html#secret-manager-2
 -    https://github.com/google-github-actions/setup-gcloud?tab=readme-ov-file
 -    https://github.com/google-github-actions/auth?tab=readme-ov-file#direct-wif
 -    https://github.com/google-github-actions/auth/blob/main/docs/EXAMPLES.md
 -    https://www.youtube.com/watch?v=ZgVhU5qvK1M
 -    https://www.youtube.com/watch?v=BCoxv19yESw
 

