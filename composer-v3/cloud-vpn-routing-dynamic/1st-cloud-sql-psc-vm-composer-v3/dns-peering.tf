/* resource "google_dns_managed_zone" "peering_zone" {
  depends_on = [google_compute_network.nw1-vpc]

  name        = "manual-sql-zone"
  dns_name    = "sql.goog."
  description = "Manual DNS Zone for SQL"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "projects/${var.project_id}/global/networks/nw1-vpc"
    }
  }

  peering_config {
    target_network {
      network_url = "projects/${var.project_id_2}/global/networks/nw1-vpc"
    }
  }
}
 */