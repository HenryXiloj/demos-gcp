resource "google_project_iam_member" "member-role-sql" {
  depends_on = [google_service_account.service_account_sql]

  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudsql.editor",
    "roles/cloudsql.admin",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.secretVersionManager",
    "roles/resourcemanager.projectIamAdmin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.service_account_sql.email}"
}

resource "google_project_iam_member" "ci-role" {
  depends_on = [google_service_account.service_account_ci]

  for_each = toset([
    "roles/compute.admin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.service_account_ci.email}"
}

resource "google_project_iam_member" "member-role" {
  depends_on = [google_service_account.service_account]

  for_each = toset([
    "roles/pubsub.editor",
    "roles/cloudfunctions.developer",
    "roles/cloudscheduler.jobRunner",
    "roles/artifactregistry.repoAdmin"
  ])
  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

/*resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}


resource "local_file" "sa_json_file" {
  content  = base64decode(google_service_account_key.mykey.private_key)
  filename = "${path.module}/cloudfunction-sa-key.json"

}*/


