# Create the Cloud Scheduler job
resource "google_cloud_scheduler_job" "first_scheduler_job" {
  depends_on = [
    resource.google_pubsub_topic.topic-dv-01
  ]
  project     = var.project_id
  region      = var.region
  name        = "first-scheduler-job"
  description = "This job triggers for Cloud Function"
  schedule    = "*/5 * * * *" #The job is scheduled to run every 5 minutes

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.topic-dv-01.id
    data       = base64encode("Hello Cloud Function!")
  }


}

