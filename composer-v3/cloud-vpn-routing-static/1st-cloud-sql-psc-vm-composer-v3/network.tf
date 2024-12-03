# VPC Network: Main VPC for terraform-workspace-437404
resource "google_compute_network" "nw1-vpc" {
  project                 = var.project_id
  name                    = "nw1-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Subnet: Private IP range for internal services
resource "google_compute_subnetwork" "nw1-subnet1" {
  name                     = "nw1-vpc-sub1-${var.region}"
  network                  = google_compute_network.nw1-vpc.id
  ip_cidr_range            = "10.10.1.0/24"
  region                   = var.region
  private_ip_google_access = true
}

# Firewall: Allow internal traffic within the VPC
resource "google_compute_firewall" "nw1-internal-allow" {
  name    = "nw1-vpc-internal-allow"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.10.0.0/16", "10.20.0.0/16"] # Add peer network CIDR
  priority      = 1100
}

# Firewall: Allow PostgreSQL and Cloud SQL Proxy traffic
resource "google_compute_firewall" "allow_postgres_vpc" {
  name    = "allow-postgres-vpc"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307", "3306"]
  }

  source_ranges = ["10.10.0.0/16", "10.20.0.0/16", "100.64.0.0/10"]
  priority      = 900
  direction     = "INGRESS"
}

# Firewall: Allow Cloud SQL Proxy egress
resource "google_compute_firewall" "allow_sql_proxy_egress" {
  name    = "allow-sql-proxy-egress"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307", "3306"]
  }

  direction          = "EGRESS"
  destination_ranges = ["10.10.0.0/16", "10.20.0.0/16", "100.64.0.0/10"]
  priority           = 1000
}

/* # VPC Peering to gcp-project1-442623
resource "google_compute_network_peering" "peering_to_project2" {
  name                 = "peering-to-project2"
  network              = google_compute_network.nw1-vpc.id
  peer_network         = "projects/gcp-project1-442623/global/networks/nw1-vpc"
  
  # Optional: Allow full communication
  export_custom_routes = true
  import_custom_routes = true
}

# Global IP Address for VPC Peering
resource "google_compute_global_address" "private_ip_address" {
  name          = google_compute_network.nw1-vpc.name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.nw1-vpc.name
}
 */


# Firewall: Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow SSH from all IPs (adjust for security)
  target_tags   = ["allow-ssh"]
}

# Firewall: Allow ICMP (Ping)
resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # Allow ping from all IPs
  target_tags   = ["psc-test"]
}

