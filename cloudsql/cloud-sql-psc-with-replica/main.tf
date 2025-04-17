/***
********************Cloud SQL Instance with PSC connectivity******************************
*****************************************************************
*/
resource "google_sql_database_instance" "psc_instance_test" {
  project             = var.project_id
  name                = "psc-instance-test"
  region              = var.region
  database_version    = "POSTGRES_17"
  deletion_protection = "false"

  settings {
    tier              = "db-perf-optimized-N-2"
    edition           = "ENTERPRISE_PLUS"
    availability_type = "REGIONAL"
    disk_autoresize   = true
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id]
      }
      ipv4_enabled = false
      ssl_mode     = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

resource "google_sql_database_instance" "psc_instance_replica" {

  depends_on = [google_sql_database_instance.psc_instance_test]

  project              = var.project_id
  name                 = "psc-instance-test-replica"
  master_instance_name = google_sql_database_instance.psc_instance_test.name
  region               = var.sec_region
  database_version     = "POSTGRES_17"

  settings {
    tier              = "db-perf-optimized-N-2"
    edition           = "ENTERPRISE_PLUS"
    availability_type = "REGIONAL"
    disk_autoresize   = true

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    user_labels = {
      environment = "test"
      type        = "read-replica"
      role        = "analytics"
    }

    ip_configuration {
      ipv4_enabled = false
      ssl_mode     = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id]
      }
    }


  }

  deletion_protection = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_sql_database" "my-database4" {
  depends_on = [google_sql_database_instance.psc_instance_test]

  project         = var.project_id
  name            = "my-database4"
  instance        = google_sql_database_instance.psc_instance_test.name
  deletion_policy = "ABANDON"
}

resource "google_sql_user" "myuser4" {

  depends_on = [google_sql_database_instance.psc_instance_test]

  project  = var.project_id
  name     = "henry"
  password = "hxi123"
  instance = google_sql_database_instance.psc_instance_test.name
}

