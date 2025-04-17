resource "google_service_account" "cloudsql_service_account" {
  project      = var.project_id
  account_id   = "cloudsql-service-account-id"
  display_name = "Service Account for Cloud SQL"
}

resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.cloudsql_service_account]

  for_each = toset([
    "roles/cloudsql.admin",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.secretVersionManager"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.cloudsql_service_account.email}"
}
