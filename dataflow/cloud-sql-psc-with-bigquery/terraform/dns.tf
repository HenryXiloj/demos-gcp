# DNS Managed Zone
resource "google_dns_managed_zone" "cloud_sql_dns_zone" {
  depends_on = [google_compute_network.nw1-vpc,
  data.google_sql_database_instance.service_attchment]
  name        = "cloud-sql-dns-zone"
  project     = var.project_id
  description = "DNS zone for the Cloud SQL instance"
  dns_name    = data.google_sql_database_instance.service_attchment.dns_name
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.nw1-vpc.id
    }
  }
}

# DNS Record Set
resource "google_dns_record_set" "cloud_sql_dns_record" {
  depends_on = [google_compute_network.nw1-vpc,
  data.google_sql_database_instance.service_attchment]

  project      = var.project_id
  name         = data.google_sql_database_instance.service_attchment.dns_name
  managed_zone = google_dns_managed_zone.cloud_sql_dns_zone.name # Name of the 
  type         = "A"
  ttl          = 300
  rrdatas      = var.private_google_access_ips
}

