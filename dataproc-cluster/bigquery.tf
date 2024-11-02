# Define a BigQuery dataset
resource "google_bigquery_dataset" "example_dataset" {
  dataset_id = "example_dataset" # Change to your preferred dataset name
  project    = var.project_id
  location   = var.region
}

# Define the first BigQuery table
resource "google_bigquery_table" "table1" {
  depends_on          = [google_storage_bucket_object.scripts]
  dataset_id          = google_bigquery_dataset.example_dataset.dataset_id
  table_id            = "table1"
  project             = var.project_id
  deletion_protection = false
  schema              = <<EOF
[
  {
    "name": "id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "age",
    "type": "INTEGER",
    "mode": "NULLABLE"
  }
]
EOF
}

# Load CSV data into BigQuery table1
resource "google_bigquery_job" "load_table1" {
  depends_on = [google_storage_bucket_object.scripts, google_bigquery_table.table1]
  job_id     = "load-table1-job"
  project    = var.project_id
  location   = var.region

  load {
    destination_table {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.example_dataset.dataset_id
      table_id   = google_bigquery_table.table1.table_id
    }

    source_uris       = ["gs://${google_storage_bucket.static.name}/table1_data.csv"]
    source_format     = "CSV"
    skip_leading_rows = 1
    field_delimiter   = ","
    write_disposition = "WRITE_TRUNCATE"

  }

}

# Define the second BigQuery table
resource "google_bigquery_table" "table2" {
  depends_on          = [google_storage_bucket_object.scripts]
  dataset_id          = google_bigquery_dataset.example_dataset.dataset_id
  table_id            = "table2"
  project             = var.project_id
  deletion_protection = false
  schema              = <<EOF
[
  {
    "name": "id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "age",
    "type": "INTEGER",
    "mode": "NULLABLE"
  }
]
EOF
}

# Define the third BigQuery table for non-duplicate records
resource "google_bigquery_table" "table3" {
  dataset_id          = google_bigquery_dataset.example_dataset.dataset_id
  table_id            = "table3"
  project             = var.project_id
  deletion_protection = false
  schema              = <<EOF
[
  {
    "name": "id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "age",
    "type": "INTEGER",
    "mode": "NULLABLE"
  }
]
EOF
}