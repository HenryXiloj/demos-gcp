/***
********************private IP VPC******************************
*****************************************************************
*/
resource "google_sql_database_instance" "my_private_instance" {

  depends_on = [google_service_networking_connection.private_vpc_connection]


  project          = var.project_id
  name             = "private-instance"
  region           = var.region
  database_version = "POSTGRES_17"

  deletion_protection = false

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.nw1-vpc.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
}

resource "google_sql_database_instance" "my_private_replica" {
  name             = "private-replica"
  project          = var.project_id
  region           = var.sec_region
  database_version = "POSTGRES_17"

  master_instance_name = google_sql_database_instance.my_private_instance.name
  deletion_protection = false
  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.nw1-vpc.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "my-database2" {
  depends_on = [google_sql_database_instance.my_private_instance]

  project         = var.project_id
  name            = "my-database2"
  instance        = google_sql_database_instance.my_private_instance.name
  deletion_policy = "DELETE"
}

resource "google_sql_user" "myuser2" {

  depends_on = [google_sql_database_instance.my_private_instance]

  project  = var.project_id
  name     = "henry"
  password = "hxi123"
  instance = google_sql_database_instance.my_private_instance.name
}
