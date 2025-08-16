resource "google_storage_bucket" "test_bucket_dv01" {
  name     = "test_bucket_dv01"
  location = var.region
}

resource "google_storage_bucket_object" "srccode" {
  depends_on = [
    resource.google_storage_bucket.test_bucket_dv01
  ]
  name   = "function-source.zip"
  bucket = google_storage_bucket.test_bucket_dv01.name
  source = "java-sources/function-source.zip"
}