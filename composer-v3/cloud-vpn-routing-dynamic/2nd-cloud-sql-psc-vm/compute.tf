resource "google_compute_address" "internal_address" {
  project      = var.project_id
  name         = "internal-address"
  region       = var.region
  address_type = "INTERNAL"
  address      = var.private_google_access_ips[0]
  subnetwork   = google_compute_subnetwork.nw1-subnet1.name
}

resource "google_compute_address" "vpn_static_ip" {
  name    = "vpn-static-ip"
  region  = var.region
  project = var.project_id
}

data "google_sql_database_instance" "service_attchment" {
  depends_on = [google_sql_database_instance.psc_instance]
  name       = resource.google_sql_database_instance.psc_instance.name
}

data "google_sql_database_instance" "dns_name" {
  depends_on = [google_sql_database_instance.psc_instance]
  name       = resource.google_sql_database_instance.psc_instance.name
}


# Forwarding Rule for PSC Service Attachment
resource "google_compute_forwarding_rule" "psc_service_attachment_link" {
  depends_on = [google_compute_address.internal_address,
    google_compute_network.nw1-vpc,
  data.google_sql_database_instance.service_attchment]
  name                  = "psc-service-attachment-link"
  provider              = google-beta
  project               = var.project_id
  region                = var.region
  ip_address            = google_compute_address.internal_address.self_link
  network               = google_compute_network.nw1-vpc.id
  load_balancing_scheme = ""
  target                = data.google_sql_database_instance.service_attchment.psc_service_attachment_link
}

