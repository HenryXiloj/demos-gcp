resource "google_dataproc_cluster" "mycluster" {
  depends_on = [google_service_account.dp_service_account,
    google_project_service.required_apis,
    google_storage_bucket.dataproc_staging_bucket,
    google_compute_subnetwork.nw1-subnet1,
  google_storage_bucket_object.scripts]

  name    = "mycluster"
  region  = var.region
  project = var.project_id

  graceful_decommission_timeout = "120s"

  cluster_config {
    # Specify the custom staging bucket if needed
    staging_bucket = google_storage_bucket.dataproc_staging_bucket.name

    # Master node configuration
    master_config {
      num_instances = 1
      machine_type  = "n2-standard-4"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 1024
      }
    }

    # Worker node configuration
    worker_config {
      num_instances = 2
      machine_type  = "n2-standard-4"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 1024
      }
    }

    # Image version and optional components
    software_config {
      image_version       = "2.2-debian12"
      optional_components = ["JUPYTER"]
    }

    # Network configuration
    gce_cluster_config {
      subnetwork       = google_compute_subnetwork.nw1-subnet1.id
      internal_ip_only = true
      service_account  = google_service_account.dp_service_account.email
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      script      = "gs://${google_storage_bucket.static.name}/startup_script.sh"
      timeout_sec = 500
    }
  }
}  