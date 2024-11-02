locals {
  scripts = {
    "bq_compare_insert.py"    = "resources/bq_compare_insert.py",
    "spark_random_numbers.py" = "resources/spark_random_numbers.py",
    "table1_data.csv"         = "resources/table1_data.csv",
    "startup_script.sh"       = "resources/startup_script.sh"
  }
}

resource "google_storage_bucket" "dataproc_staging_bucket" {
  name                        = "dataproc-staging-${var.project_id}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}


resource "google_storage_bucket" "static" {
  name          = "etl-scripts-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_object" "scripts" {
  depends_on = [google_storage_bucket.static]
  for_each   = local.scripts
  name       = each.key
  bucket     = google_storage_bucket.static.name
  source     = each.value
}

