resource "google_composer_environment" "test" {

  depends_on = [
    google_sql_database_instance.my_private_instance,
    google_service_account.cloudsql_service_account,
    google_compute_network.nw1-vpc,
  google_compute_subnetwork.nw1-subnet1]

  name     = "example-composer-env-tf-c3"
  region   = var.region
  provider = google-beta

  config {

    enable_private_environment = true

    software_config {
      image_version = "composer-3-airflow-2"

      pypi_packages = {
        pg8000                     = "==1.31.2"
        cloud-sql-python-connector = "==1.12.1"
        google-auth                = "==2.35.0"
        google-auth-oauthlib       = "==1.2.1"
      }
    }

    workloads_config {
      scheduler {
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
        count      = 1
      }
      triggerer {
        cpu       = 0.5
        memory_gb = 1
        count     = 1
      }
      dag_processor {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
        count      = 1
      }
      web_server {
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
      }
      worker {
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
        min_count  = 1
        max_count  = 1
      }

    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"

    node_config {
      network         = google_compute_network.nw1-vpc.id
      subnetwork      = google_compute_subnetwork.nw1-subnet1.id
      service_account = google_service_account.cloudsql_service_account.name
    }
  }
}