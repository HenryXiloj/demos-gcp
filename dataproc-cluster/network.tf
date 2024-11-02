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

# Cloud Router for NAT
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.nw1-vpc.id
  region  = var.region
  project = var.project_id
}

# Cloud NAT configuration for internet access
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY" # Automatically allocate NAT IPs
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm                   = 64
}

# Firewall Rule (Internal Traffic): Allows unrestricted internal traffic (both TCP and UDP) within the VPC.
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

# Firewall Rule (SSH over IAP): Allows SSH access via IAP to VMs on port 22.
resource "google_compute_firewall" "allow-ssh-iap" {
  name    = "nw1-vpc-allow-ssh-iap"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  # Allow TCP traffic on port 22 for SSH access.
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Define the source IP range for IAP traffic.
  source_ranges = ["35.235.240.0/20"] # IAP IP range for accessing Google Cloud VMs.
  priority      = 1000
  direction     = "INGRESS"
}

# Firewall Rule (Egress Traffic): Allows outbound internet access for downloading packages.
resource "google_compute_firewall" "allow-egress-internet" {
  name    = "nw1-vpc-allow-egress-internet"
  project = var.project_id
  network = google_compute_network.nw1-vpc.id

  # Allow HTTP and HTTPS traffic to the internet.
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Allow egress to the internet.
  destination_ranges = ["0.0.0.0/0"] # All external IP addresses
  priority           = 1000
  direction          = "EGRESS"
}
