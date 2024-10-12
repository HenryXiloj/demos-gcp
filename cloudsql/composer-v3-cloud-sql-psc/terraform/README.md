# Connecting Airflow 2 in Composer 3 to Cloud SQL via Private Service Connect (PSC)

This project demonstrates how to connect Airflow 2 in Google Cloud Composer 3 to a Cloud SQL instance using Private Service Connect (PSC). It uses Terraform to set up the necessary infrastructure and provides instructions for configuring and running the connection.

## Prerequisites

- Google Cloud Platform account
- Terraform installed
- `gcloud` CLI installed and configured
- Access to Google Cloud Composer and Cloud SQL

## Setup

1. Clone this repository to your local machine.

2. Download the Cloud SQL Proxy binary:
   ```bash
   URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.13.0"
   curl "$URL/cloud-sql-proxy.linux.amd64" -o cloud-sql-proxy
   chmod +x cloud-sql-proxy
   ```

3. Upload the Cloud SQL Proxy binary to a Google Cloud Storage bucket:
   ```bash
   gsutil cp cloud-sql-proxy gs://<my-bucket-name>
   ```

4. Update the `terraform.tfvars` file with your project details:
   ```hcl
   project_id     = "your-project-id"
   project_number = "your-project-number"
   region         = "us-central1"
   zone           = "us-central1-a"
   sec_region     = "us-west1"
   sec_zone       = "us-west1-a"
   ```

5. Initialize Terraform and apply the configuration:
   ```bash
   terraform init
   terraform fmt
   terraform validate
   terraform plan
   terraform apply -auto-approve
   ```

6. Create a Private Service Connect endpoint:

   ```bash
   gcloud sql instances describe psc-instance --project <PROJECT-ID>
   ```

   ```bash
   gcloud compute forwarding-rules create psc-service-attachment-link --address=internal-address --project=<PROJECT-ID> --region=us-central1 --network=nw1-vpc --target-service-attachment=<pscServiceAttachmentLink>
   ```

   ```bash
   gcloud compute forwarding-rules describe psc-service-attachment-link --project <PROJECT-ID>  --region us-central1
   ```  

7. Configure a DNS managed zone and a DNS record: 
   ```bash
   gcloud dns managed-zones create cloud-sql-dns-zone --project=<PROJECT-ID> --description="DNS zone for the Cloud SQL instance" --dns-name=<DNS-ENTRY> --networks=nw1-vpc --visibility=private
   ```

   ```bash
   gcloud dns record-sets create <DNS-ENTRY> --project=<PROJECT-ID> --type=A --rrdatas=10.10.1.10 --zone=cloud-sql-dns-zone
   ```       

## Composer Configuration

Composer v3 will automatically create a bucket with the following structure:
```
<region>-<my-composer-name-ID>-bucket/
├── dags/
├── data/
├── logs/
└── plugins/
```

Upload your `cloud_sql_proxy_psc_dag.py` file to the `dags/` directory using `gsutil` or manually through the Google Cloud Console.

## Running the DAG

1. Access the Airflow 2 UI through Google Cloud Composer.
2. Locate your uploaded DAG in the DAGs list.
3. Enable and trigger the DAG to run.

## Project Structure

- `provider.tf`: Defines the required providers and their versions.
- `variable.tf`: Declares variables used throughout the Terraform configuration.
- `terraform.tfvars`: Sets values for the declared variables.
- `network.tf`: Configures the VPC network and subnets.
- `compute.tf`: Sets up compute resources, including internal IP addresses.
- `iam.tf`: Manages IAM roles and service accounts.
- `bucket.tf`: Creates a Google Cloud Storage bucket for the Cloud SQL Proxy binary.
- `main.tf`: Configures the Cloud SQL instance with PSC connectivity.
- `composer.tf`: Sets up the Google Cloud Composer environment.

## Troubleshooting

If you encounter any issues:

1. Check the Airflow logs in the Composer environment.
2. Verify that all resources have been created correctly in the Google Cloud Console.
3. Ensure that the Cloud SQL Proxy binary is correctly uploaded and accessible.
4. Double-check the IAM permissions for the Composer service account.

## Images

For visual reference, please see the following images in your project documentation:

1. ![Image 1](path/to/image1.png)
   *Description of what Image 1 shows*

2. ![Image 2](path/to/image2.png)
   *Description of what Image 2 shows*

3. ![Image 3](path/to/image3.png)
   *Description of what Image 3 shows*

4. ![Image 4](path/to/image4.png)
   *Description of what Image 4 shows*

## Contributing

Contributions to this project are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## License

[MIT License](https://opensource.org/licenses/MIT)

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.