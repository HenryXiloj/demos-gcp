resource "google_storage_bucket" "data_bucket" {
  depends_on    = [google_project_iam_member.member_role]
  name          = "${var.project_id}-data-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "temp_dir_placeholder" {
  name    = "temp-dir/" # trailing slash indicates a folder
  bucket  = google_storage_bucket.data_bucket.name
  content = " " # Single space instead of empty string
}

/***
********************Cloud SQL Instance with PSC connectivity******************************
*****************************************************************
*/
resource "google_sql_database_instance" "psc_instance" {
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

  database_flags {
    name  = "cloudsql.logical_decoding"
    value = "on"
  }

  database_flags {
    name  = "max_replication_slots"
    value = "10"
  }

  database_flags {
    name  = "max_wal_senders"
    value = "10"
  }

  database_flags {
    name  = "wal_sender_timeout"
    value = "0"
  }
  }
}

resource "google_sql_database_instance" "psc_instance_replica" {

  depends_on = [google_sql_database_instance.psc_instance]

  project              = var.project_id
  name                 = "psc-instance-test-replica"
  master_instance_name = google_sql_database_instance.psc_instance.name
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

  database_flags {
    name  = "cloudsql.logical_decoding"
    value = "on"
  }

  database_flags {
    name  = "max_replication_slots"
    value = "10"
  }

  database_flags {
    name  = "max_wal_senders"
    value = "10"
  }

  database_flags {
    name  = "wal_sender_timeout"
    value = "0"
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

  deletion_protection = false

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_sql_database" "my-database4" {
  depends_on = [google_sql_database_instance.psc_instance]

  project         = var.project_id
  name            = "my-database4"
  instance        = google_sql_database_instance.psc_instance.name
  deletion_policy = "ABANDON"
}

resource "google_sql_user" "myuser4" {

  depends_on = [google_sql_database_instance.psc_instance]

  project  = var.project_id
  name     = "henry"
  password = "hxi123"
  instance = google_sql_database_instance.psc_instance.name
}


###############BigQuery###############################
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "sample_dataset"
  location   = var.region
}

resource "google_bigquery_table" "customers" {
  depends_on          = [google_project_iam_member.member_role]
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "customers"
  deletion_protection = false
  schema = jsonencode([
    { "name" : "customer_id", "type" : "INTEGER", "mode" : "NULLABLE" },
    { "name" : "first_name", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "last_name", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "email", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "phone", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "address", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "registration_date", "type" : "DATE", "mode" : "NULLABLE", "defaultValueExpression" : "CURRENT_DATE()" },
    { "name" : "loyalty_points", "type" : "INTEGER", "mode" : "NULLABLE", "defaultValueExpression" : "0" }
  ])
}


resource "google_bigquery_table" "failed_customers" {
  depends_on          = [google_project_iam_member.member_role]
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "failed_customers"
  deletion_protection = false
  schema = jsonencode([
    { "name" : "error_message", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "error_stack", "type" : "STRING", "mode" : "NULLABLE" },
    { "name" : "timestamp", "type" : "TIMESTAMP", "mode" : "NULLABLE" },
    { "name" : "original_data", "type" : "STRING", "mode" : "NULLABLE" }
  ])
}
