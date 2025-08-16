resource "google_secret_manager_secret" "secret-basic" {
  project   = var.project_id
  secret_id = "password-db"

  labels = {
    label = "password-db"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }

    }
  }
}

resource "random_password" "secret_password" {
  length           = 20
  special          = true
  override_special = "!@#$%*"
}

resource "google_secret_manager_secret_version" "password_secret_version" {

  depends_on = [google_secret_manager_secret.secret-basic,
  random_password.secret_password]

  secret      = google_secret_manager_secret.secret-basic.id
  secret_data = random_password.secret_password.result
}