# VPC Network: Required to define an isolated virtual network within GCP.
# This is the main network that will be used for all your private services and Cloud SQL PSC.
resource "google_compute_network" "nw1-vpc" {
  project                 = var.project_id
  name                    = "nw1-vpc"
  auto_create_subnetworks = false # Manually create subnets for better control.
  mtu                     = 1460  # Recommended MTU size for Google Cloud networks.
}

# Subnet 1: Required to define a private IP range for internal services in a specific region.
# The "private_ip_google_access" allows resources in this subnet to access Google services privately.
resource "google_compute_subnetwork" "nw1-subnet1" {
  name                     = "nw1-vpc-sub1-${var.region}"
  network                  = google_compute_network.nw1-vpc.id
  ip_cidr_range            = "10.10.1.0/24" # Define the private IP range for this subnet.
  region                   = var.region
  private_ip_google_access = true # Needed to access Google services (like Cloud SQL) without a public IP.
}


# Firewall Rule (Internal Traffic): Allows unrestricted internal traffic (both TCP and UDP) within the VPC.
# Ensures that all internal communications across subnets can occur without restriction.
resource "google_compute_firewall" "nw1-internal-allow" {
  name    = "nw1-vpc-internal-allow"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  # Allow ICMP for internal network diagnostics.
  allow {
    protocol = "icmp"
  }

  # Allow UDP and TCP traffic across all ports within the internal CIDR.
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  # Define the IP range for internal traffic (your entire VPC).
  source_ranges = ["10.10.0.0/16"] # Internal range covering all subnets within the VPC.
  priority      = 1100
}

resource "google_compute_firewall" "allow_postgres_vpc" {
  name    = "allow-postgres-vpc"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307", "3306"]
  }

  source_ranges = ["10.10.0.0/16", "100.64.0.0/10"] # Cover both internal and Airflow worker traffic
  priority      = 900                               # Ensure it's applied over deny-all rules
  direction     = "INGRESS"
}

resource "google_compute_firewall" "allow_sql_proxy_egress" {
  name    = "allow-sql-proxy-egress"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307", "3306"] # Allow egress on 3307 for Cloud SQL Proxy
  }

  direction          = "EGRESS"
  destination_ranges = ["10.10.0.0/16", "100.64.0.0/10"] # Cloud SQL's internal IP range
  priority           = 1000
}

# Global IP Address for VPC Peering: Used to reserve a range of IP addresses for VPC peering with Google services.
# Cloud SQL PSC requires a reserved range of internal IPs to communicate with services over VPC peering.
resource "google_compute_global_address" "private_ip_address" {
  name          = google_compute_network.nw1-vpc.name
  purpose       = "VPC_PEERING" # Specifies that this is for VPC peering.
  address_type  = "INTERNAL"    # Use an internal IP address.
  prefix_length = 16            # Define the size of the address space (larger space = more addresses).
  network       = google_compute_network.nw1-vpc.name
}

# VPC Peering Connection for Private Service Connect (PSC): Required to establish a VPC peering connection with Google services.
# This enables Cloud SQL to communicate privately with the VPC over the reserved IP range.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.nw1-vpc.id
  service                 = "servicenetworking.googleapis.com"                      # Google service for VPC peering.
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name] # Reserved IP range for peering.
}
