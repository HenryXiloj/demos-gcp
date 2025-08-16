# Create the Pub/Sub topic
resource "google_pubsub_topic" "topic-dv-01" {
  project = var.project_id
  name    = "topic-dv-01"

  labels = {
    label = "topic-dv-01"
  }
}

resource "google_pubsub_subscription" "sub-dv-01" {
  name  = "topic-dv-01-subscription"
  topic = google_pubsub_topic.topic-dv-01.id

  labels = {
    foo = "topic-dv-01-subscription"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering = false
}