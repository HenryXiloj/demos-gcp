/***
********************private IP VPC******************************
*****************************************************************
*/
resource "google_sql_database_instance" "my_private_instance" {

  depends_on = [google_service_networking_connection.private_vpc_connection]


  project          = var.project_id
  name             = "private-instance"
  region           = var.region
  database_version = "POSTGRES_15"

  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.nw1-vpc.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
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
  name     = "<MY_USER>"
  password = "<MY_PASSWORD>"
  instance = google_sql_database_instance.my_private_instance.name
}
