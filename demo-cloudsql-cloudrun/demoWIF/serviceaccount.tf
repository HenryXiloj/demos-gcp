# Service account associated with workload identity pool
resource "google_service_account" "github-svc" {
  project      = var.project_id
  account_id   = "gcp-github-access"
  display_name = "Service Account - github-svc"
}

resource "google_project_iam_member" "github-access" {

  for_each = toset([
    "roles/owner",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/iam.serviceAccountAdmin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.github-svc.email}"
}