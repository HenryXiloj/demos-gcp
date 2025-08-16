####PUBLIC #################
resource "google_compute_instance" "public-instance-1" {

  name         = "public-instance-1"
  machine_type = "e2-medium"
  zone         = var.zone


  tags = ["http-server", "https-server"]

  boot_disk {
    auto_delete = true
    device_name = "public-instance-1"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240213"
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

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/terraform-workspace-413615/regions/us-central1/subnetworks/nw1-vpc-sub1-us-central1"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  metadata_startup_script = "echo hello public instance > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.service_account_ci.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }


}

###VPC###
resource "google_compute_instance" "vpc-instance" {

  depends_on = [
    resource.google_compute_network.vpc_network,
    resource.google_compute_subnetwork.private_network
  ]

  name         = "vpc-instance"
  machine_type = "n2-standard-2"
  zone         = var.zone

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.private_network.self_link
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hello private instance > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.service_account_ci.email
    scopes = ["cloud-platform"]
  }
}
