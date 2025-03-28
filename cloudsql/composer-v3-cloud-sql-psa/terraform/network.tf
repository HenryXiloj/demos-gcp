#"10.113.0.0/24"  range cloud sql psa -> private IP. 

# VPC Network: Defines the private network for internal services and Cloud SQL (PSA).
resource "google_compute_network" "nw1-vpc" {
  project                 = var.project_id
  name                    = "nw1-vpc"
  auto_create_subnetworks = false # Better control by manually creating subnets.
  mtu                     = 1460  # Recommended MTU size for GCP.
}

# Subnet for internal resources. Enables access to Google APIs via private IP.
resource "google_compute_subnetwork" "nw1-subnet1" {
  name                     = "nw1-vpc-sub1-${var.region}"
  network                  = google_compute_network.nw1-vpc.id
  ip_cidr_range            = "10.10.1.0/24"
  region                   = var.region
  private_ip_google_access = true
}

# Firewall: Allow all internal traffic (ICMP, TCP, UDP) within the VPC.
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

  # Includes subnet range (10.10.1.0/24) and Cloud SQL PSA range.
  source_ranges = ["10.10.0.0/16", "10.113.0.0/24"]
  priority      = 1100
}

# Firewall: Allow incoming SQL traffic from internal and Composer worker ranges.
resource "google_compute_firewall" "allow_postgres_vpc" {
  name    = "allow-postgres-vpc"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307", "3306"]
  }

  # Covers internal subnet (10.10.1.0/24), PSA range, and Composer NATs.
  source_ranges = ["10.10.0.0/16", "10.113.0.0/24", "100.64.0.0/10"]
  priority      = 900
  direction     = "INGRESS"
}

# Firewall: Allow outbound SQL traffic to internal and Cloud SQL ranges.
resource "google_compute_firewall" "allow_sql_proxy_egress" {
  name    = "allow-sql-proxy-egress"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307", "3306"]
  }

  # Covers destinations for PSA and internal SQL targets.
  direction          = "EGRESS"
  destination_ranges = ["10.10.0.0/16", "10.113.0.0/24", "100.64.0.0/10"]
  priority           = 1000
}

# Reserve internal IP range for VPC peering with Google services (needed for PSA).
resource "google_compute_global_address" "private_ip_address" {
  name          = google_compute_network.nw1-vpc.name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.nw1-vpc.name
}

# Establish VPC peering with Google services to enable Cloud SQL PSA.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.nw1-vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
