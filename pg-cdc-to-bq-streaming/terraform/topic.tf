resource "google_pubsub_topic" "my_topic" {
  project = var.project_id
  name    = "my_topic"

  labels = {
    label = "my_topic"
  }
}

resource "google_pubsub_subscription" "my_subcription" {
  project = var.project_id
  name    = "my_subcription"
  topic   = google_pubsub_topic.my_topic.id

  labels = {
    environment = "dv"
  }

  # Retain messages for 1 hour if unacknowledged
  message_retention_duration = "3600s"
  retain_acked_messages      = true

  # Messages must be acknowledged within 30 seconds
  ack_deadline_seconds = 30


  retry_policy {
    minimum_backoff = "10s" # Retry failed messages after 10 seconds
  }

  enable_message_ordering = false # Set to true if ordering is required
}