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
        allowed_consumer_projects = [var.project_id]
      }
      ipv4_enabled = false
    }

    availability_type = "REGIONAL"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
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

  depends_on = [google_sql_database_instance.psc_instance]

  project  = var.project_id
  name     = "henry"
  password = "hxi123"
  instance = google_sql_database_instance.psc_instance.name
}
