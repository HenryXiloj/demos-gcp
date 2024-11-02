locals {
  required_apis = [
    "dataproc.googleapis.com",
    "compute.googleapis.com"
  ]
}

resource "google_service_account" "dp_service_account" {
  project      = var.project_id
  account_id   = "dp-service-account-id"
  display_name = "Service Account for Dataproc cluster"
}

# Enable multiple APIs using a for_each loop
resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.dp_service_account]

  for_each = toset([
    "roles/dataproc.admin",
    "roles/dataproc.worker",
    "roles/storage.objectAdmin",
    "roles/cloudsql.editor",
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.secretVersionManager",
    "roles/iam.serviceAccountTokenCreator"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.dp_service_account.email}"
}
