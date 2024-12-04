resource "google_service_account" "cloudsql_service_account" {
  project      = var.project_id
  account_id   = "cloudsql-service-account-id"
  display_name = "Service Account for Cloud SQL"
}

resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.cloudsql_service_account,
    google_compute_network.nw1-vpc,
  google_compute_subnetwork.nw1-subnet1]

  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudsql.editor",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.secretVersionManager",
    "roles/composer.worker",
    "roles/storage.objectUser",
    "roles/compute.viewer",
    "roles/iam.serviceAccountTokenCreator",
    "roles/compute.admin",
    "roles/dns.peer",
    "roles/dns.admin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.cloudsql_service_account.email}"
}

#####https://cloud.google.com/composer/docs/composer-2/create-environments#grant-permissions 
resource "google_service_account_iam_member" "custom_service_account" {
  provider           = google-beta
  service_account_id = google_service_account.cloudsql_service_account.id
  role               = "roles/composer.ServiceAgentV2Ext"
  member             = "serviceAccount:service-${var.project_number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}
