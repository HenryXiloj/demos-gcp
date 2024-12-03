resource "google_dns_managed_zone" "peering_zone" {
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

resource "google_compute_vpn_gateway" "vpn_gateway" {
  depends_on = [google_compute_network.nw1-vpc]
  name        = "vpn-1-${var.project_id}"
  description = "vpn-1-${var.project_id}"
  network     = "projects/${var.project_id}/global/networks/nw1-vpc"
  region      = var.region
}

resource "google_compute_forwarding_rule" "rule_esp" {
  depends_on            = [google_compute_address.vpn_static_ip, google_compute_vpn_gateway.vpn_gateway]
  name                  = "vpn-1-${var.project_id}-rule-esp"
  description           = "Forwarding rule for ESP"
  ip_protocol           = "ESP"
  target                = google_compute_vpn_gateway.vpn_gateway.id
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.vpn_static_ip.address
}

resource "google_compute_forwarding_rule" "rule_udp500" {
  name                  = "vpn-1-${var.project_id}-rule-udp500"
  description           = "Forwarding rule for UDP 500"
  ip_protocol           = "UDP"
  port_range            = "500"
  target                = google_compute_vpn_gateway.vpn_gateway.id
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.vpn_static_ip.address
}

resource "google_compute_forwarding_rule" "rule_udp4500" {
  name                  = "vpn-1-${var.project_id}-rule-udp4500"
  description           = "Forwarding rule for UDP 4500"
  ip_protocol           = "UDP"
  port_range            = "4500"
  target                = google_compute_vpn_gateway.vpn_gateway.id
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.vpn_static_ip.address
}

resource "google_compute_vpn_tunnel" "vpn_tunnel" {
  depends_on              = [google_compute_forwarding_rule.rule_esp] # Ensure ESP rule is ready
  name                    = "vpn-tunnel-1-${var.project_id}"
  description             = "vpn-tunnel-1-${var.project_id}"
  region                  = var.region
  target_vpn_gateway      = google_compute_vpn_gateway.vpn_gateway.id
  peer_ip                 = var.static_peer_second_GCP_project_IP # Peer GCP project IP
  shared_secret           = var.shared_secret
  ike_version             = 2
  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
}

resource "google_compute_route" "vpn_route" {
  depends_on          = [google_compute_vpn_tunnel.vpn_tunnel, google_compute_network.nw1-vpc] # Ensure VPN tunnel is ready
  name                = "vpn-tunnel-1-${var.project_id}-route-1"
  description         = "Route for VPN tunnel"
  network             = "projects/${var.project_id}/global/networks/nw1-vpc"
  priority            = 1000
  dest_range          = var.destination_range_in_peer_second_GCP_project # Destination range in peer GCP project
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vpn_tunnel.id
}
