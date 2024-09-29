/***
********************public IP******************************
*****************************************************************
*/

resource "google_sql_database_instance" "my_public_instance" {
  project          = var.project_id
  name             = "main-instance"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = false

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "my-database1" {
  depends_on      = [google_sql_database_instance.my_public_instance]
  project         = var.project_id
  name            = "my-database1"
  instance        = google_sql_database_instance.my_public_instance.name
  deletion_policy = "DELETE"
}

resource "google_sql_user" "myuser1" {

  depends_on = [google_sql_database_instance.my_public_instance]

  project  = var.project_id
  name     = "henry"
  password = "mypassword"
  instance = google_sql_database_instance.my_public_instance.name
}


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
  name     = "henry"
  password = "mypassword"
  instance = google_sql_database_instance.my_private_instance.name
}


