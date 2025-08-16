resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = "sa-functions-scheduler-pubsub"
  display_name = "Service Account for Cloud functions-scheduler-pubsub"
}

output "service_account_email" {
  value = google_service_account.service_account.email
}


resource "google_service_account" "service_account_ci" {
  account_id   = "service-account-vm"
  display_name = "Custom SA for VM Instance"
}

output "service_account_ci" {
  value = google_service_account.service_account_ci.email
}

resource "google_service_account" "service_account_sql" {
  project      = var.project_id
  account_id   = "service-account-sql"
  display_name = "Service Account for Cloud SQL"
}

output "service_account_sql" {
  value = google_service_account.service_account_sql.email
}