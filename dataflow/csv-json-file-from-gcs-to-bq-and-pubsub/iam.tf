
resource "google_service_account" "dataflow_service_account" {
  project      = var.project_id
  account_id   = "dataflow-service-account-id"
  display_name = "Service Account for dataflow"
}

output "service_account_email" {
  value = google_service_account.dataflow_service_account.email
}


resource "google_project_iam_member" "member_role" {
  depends_on = [google_service_account.dataflow_service_account]

  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/dataflow.admin",
    "roles/bigquery.admin",
    "roles/pubsub.admin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}
