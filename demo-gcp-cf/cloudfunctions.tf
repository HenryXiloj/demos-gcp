resource "google_cloudfunctions_function" "fun_from_tf" {

  depends_on = [
    resource.google_pubsub_topic.topic-dv-01,
    resource.google_storage_bucket_object.srccode
  ]

  name        = "fun-from-tf"
  runtime     = "java17"
  description = "This is my first function from terraform script."

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.test_bucket_dv01.name
  source_archive_object = google_storage_bucket_object.srccode.name

  timeout = 420

  entry_point = "com.henry.Backfill"

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic-dv-01.name
  }

}
