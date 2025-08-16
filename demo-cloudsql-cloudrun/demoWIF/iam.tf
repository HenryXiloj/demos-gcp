resource "google_project_service" "wif_api" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

module "gh_oidc" {
  source            = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version           = "v3.1.1"
  project_id        = var.project_id
  pool_id           = "gh-identity-pool1"
  pool_display_name = "Identity Pool"
  provider_id       = "gh-provider"
  sa_mapping = {
    (google_service_account.github-svc.account_id) = {
      sa_name   = google_service_account.github-svc.name
      attribute = "*"
    }
  }
  
}