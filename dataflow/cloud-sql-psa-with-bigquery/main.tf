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
  deletion_protection  = false
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
    { "name" : "customer_id", "type" : "INTEGER", "mode" : "REQUIRED" },
    { "name" : "first_name", "type" : "STRING", "mode" : "REQUIRED" },
    { "name" : "last_name", "type" : "STRING", "mode" : "REQUIRED" },
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
