/*
gcloud compute addresses create my-internal-address --project=terraform-workspace-413615 
--region=us-central1 --subnet=nw1-vpc-sub1-us-central1 
--addresses=10.10.1.10
*/
resource "google_compute_address" "internal_address" {
  project      = var.project_id
  name         = "internal-address"
  region       = var.region
  address_type = "INTERNAL"
  address      = "10.10.1.10"                               #"INTERNAL_IP_ADDRESS"
  subnetwork   = google_compute_subnetwork.nw1-subnet1.name #optional
}


# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

resource "google_compute_instance" "private-vm" {
  boot_disk {
    auto_delete = true
    device_name = "private-vm"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240312"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"

  metadata = {
    startup-script = "echo hello world > /home/henry_xh3/test.txt"
  }

  name = "private-vm"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = resource.google_compute_subnetwork.nw1-subnet1.id
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = resource.google_service_account.cloudsql_service_account.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "us-central1-a"
}

/*
resource "google_compute_instance" "private-vm" {

  depends_on   = [resource.google_service_account.cloudsql_service_account]
  project      = var.project_id
  name         = "private-vm"
  zone         = var.zone
  machine_type = "e2-medium"

  deletion_protection = false

  allow_stopping_for_update = true

  network_interface {
    #network = "custom_vpc_network"
    subnetwork = resource.google_compute_subnetwork.nw1-subnet1.id
    #access_config {}
  }


  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20230606"
      size  = 20
    }
  }

  metadata_startup_script =  "echo hello world > /home/henry_xh3/test.txt"

  service_account {
    email  = resource.google_service_account.cloudsql_service_account.email
    scopes = ["cloud-platform"]
  }
}
*/