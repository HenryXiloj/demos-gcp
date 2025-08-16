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
        allowed_consumer_projects = ["terraform-workspace-413615"]
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

resource "google_sql_database" "my-database3" {
  depends_on = [google_sql_database_instance.psc_instance]

  project         = var.project_id
  name            = "my-database3"
  instance        = google_sql_database_instance.psc_instance.name
  deletion_policy = "DELETE"
}

resource "google_sql_user" "myuser3" {

  depends_on = [google_sql_database_instance.psc_instance,
  google_secret_manager_secret_version.password_secret_version]

  project  = var.project_id
  name     = "henry"
  password = google_secret_manager_secret_version.password_secret_version.secret_data
  instance = google_sql_database_instance.psc_instance.name
}


/***
********************public IP******************************
*****************************************************************
*/
/*
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

  depends_on = [google_sql_database_instance.my_public_instance,
  google_secret_manager_secret_version.password_secret_version]

  project  = var.project_id
  name     = "henry"
  password = google_secret_manager_secret_version.password_secret_version.secret_data
  instance = google_sql_database_instance.my_public_instance.name
}
*/

/***
********************private IP VPC******************************
*****************************************************************
*/

/*
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

  depends_on = [google_sql_database_instance.my_private_instance,
  google_secret_manager_secret_version.password_secret_version]

  project  = var.project_id
  name     = "henry"
  password = google_secret_manager_secret_version.password_secret_version.secret_data
  instance = google_sql_database_instance.my_private_instance.name
}
*/

