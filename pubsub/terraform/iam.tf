
resource "google_service_account" "pubsub_service_account" {
  project      = var.project_id
  account_id   = "pubsub-service-account-id"
  display_name = "Service Account for Cloud SQL"
}

output "service_account_email" {
  value = google_service_account.pubsub_service_account.email
}


resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.pubsub_service_account]

  for_each = toset([
    "roles/pubsub.admin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.pubsub_service_account.email}"
}
