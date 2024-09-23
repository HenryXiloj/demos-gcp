
resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.cloudsql_service_account]

  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudsql.editor",
    "roles/cloudsql.admin",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.secretVersionManager",
    "roles/vpcaccess.serviceAgent",
    "roles/run.developer"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.cloudsql_service_account.email}"
}
