resource "google_cloud_run_service" "cloudrun-srv" {
  project  = var.project_id
  name     = "cloudrun-srv"
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        #image = "us-central1-docker.pkg.dev/terraform-workspace-413615/my-repo/quickstart-springboot:d59f80384638dfb724c243f184b1c51b64261823"
      }
      service_account_name = google_service_account.cloudsql_service_account.email
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "10"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.psc_instance.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }


  autogenerate_revision_name = true
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.cloudrun-srv.location
  project  = google_cloud_run_service.cloudrun-srv.project
  service  = google_cloud_run_service.cloudrun-srv.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
