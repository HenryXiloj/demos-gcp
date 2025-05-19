
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
    "roles/cloudsql.admin",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.secretVersionManager",
    "roles/storage.objectAdmin",
    "roles/storage.objectViewer",
    "roles/dataflow.admin",
    "roles/dataflow.worker",
    "roles/bigquery.admin",
    "roles/cloudscheduler.admin",
    "roles/compute.networkUser",
    "roles/dns.admin",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
    "roles/pubsub.admin",
    "roles/vpcaccess.serviceAgent",
    "roles/run.developer"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}
