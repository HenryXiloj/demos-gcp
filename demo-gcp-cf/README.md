# Cloud SQL Terraform and Spring Boot App

This repository contains two projects:

1. **cloud-sql-terraform**: Terraform configuration to set up a Cloud SQL instance with Private Service Connect.
2. **demo-cloudsql-cloudrun**: A Spring Boot application that connects to the Cloud SQL instance and runs on Cloud Run.
3. **frameworks-coren**: A Maven application Dummy  Framework

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

## Destroy

### Console Commands

1. Run these commands in console:

```bash
 gcloud dns record-sets delete DNS_NAME(this value come from 2.2) --type=A --zone=cloud-sql-dns-zone

 gcloud dns managed-zones delete cloud-sql-dns-zone --project=MY_PROJECT_ID

 gcloud compute forwarding-rules delete psc-service-attachment-link --region=us-central1 --project=MY_PROJECT_ID

 gcloud artifacts repositories delete my-repo --location=us-central1

 gcloud artifacts repositories delete tf-repo --location=us-central1

 gcloud run services delete springboot-run-psc --region us-central1
```


### Terraform

1. Run:

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

### Diagram
![alt text](https://raw.githubusercontent.com/HenryXiloj/demos-gcp/main/demo-gcp-cf/option2.png)
