/***
********************Cloud SQL Instance with PSC connectivity******************************
*****************************************************************
*/

resource "google_sql_database_instance" "psc_instance" {
  project          = var.project_id
  name             = "psc-instance"
  region           = var.region
  database_version = "POSTGRES_15"

  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id, "terraform-workspace-437404"]
      }
      ipv4_enabled = false
    }
    #backup_configuration {
    #  enabled = true
    #binary_log_enabled = true
    #}
    availability_type = "REGIONAL"
  }
}

resource "google_sql_database" "my-database4" {
  depends_on = [google_sql_database_instance.psc_instance]

  project         = var.project_id
  name            = "my-database4"
  instance        = google_sql_database_instance.psc_instance.name
  deletion_policy = "DELETE"
}

resource "google_sql_user" "myuser3" {

  depends_on = [google_sql_database_instance.psc_instance]

  project  = var.project_id
  name     = "henry"
  password = "hxi123"
  instance = google_sql_database_instance.psc_instance.name
}


/***
********************Virtual Machine******************************
*****************************************************************
*/

resource "google_compute_instance" "psc_test_vm" {
  depends_on = [google_service_account.cloudsql_service_account,
    google_compute_network.nw1-vpc,
  google_compute_subnetwork.nw1-subnet1]
  name         = "psc-test-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  project      = var.project_id

  tags                = ["psc-test", "allow-ssh"]
  deletion_protection = false

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.nw1-vpc.id
    subnetwork = google_compute_subnetwork.nw1-subnet1.id
    access_config {
      # Allows external IP access (if required)
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = google_service_account.cloudsql_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y dnsutils net-tools telnet
  EOT
}