resource "google_cloud_scheduler_job" "my-workflow-job" {
  depends_on = [resource.google_service_account.cloudsql_service_account,
  resource.google_workflows_workflow.batch1_workflow]

  name      = "my-workflow-job"
  schedule  = "*/45 * * * *" # every 45 mins
  time_zone = "America/Vancouver"

  http_target {
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/workflows/${var.batch1_workflow}/executions"
    http_method = "POST"
    oauth_token {
      service_account_email = google_service_account.cloudsql_service_account.email
      #"cloudsql-service-account-id@terraform-workspace-413615.iam.gserviceaccount.com"
    }
  }

  region = var.region
}

