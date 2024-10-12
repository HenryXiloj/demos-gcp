resource "google_storage_bucket" "gcs_binary_load" {
  name          = "gcs_cloud_sql_proxy_v2_13_0"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

}

