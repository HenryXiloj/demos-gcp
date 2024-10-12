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

# Subnet 2: Similar to Subnet 1 but in a secondary region. This provides multi-region redundancy or support.
resource "google_compute_subnetwork" "nw1-subnet2" {
  name                     = "nw1-vpc-sub2-${var.sec_region}"
  network                  = google_compute_network.nw1-vpc.id
  ip_cidr_range            = "10.10.2.0/24" # Define a different private IP range in the second region.
  region                   = var.sec_region
  private_ip_google_access = true # Also needed in this region for accessing Google services privately.
}

# Firewall Rule (SSH and ICMP): Needed to allow SSH access and ICMP (ping) for specific IP ranges.
# Allows access to virtual machines via SSH and pings from trusted IP addresses (source_ranges).
resource "google_compute_firewall" "nw1-ssh-icmp-allow" {
  name    = "nw1-vpc-ssh-allow"
  network = google_compute_network.nw1-vpc.id

  # Allow ICMP for network diagnostic purposes.
  allow {
    protocol = "icmp"
  }

  # Allow SSH access on port 22 to a specified IP range.
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Restrict access to a specific IP address or range for security.
  source_ranges = ["39.33.11.48/32"] # Adjust this to your IP or corporate network range.
  target_tags   = ["nw1-vpc-ssh-allow"]
  priority      = 1000 # Lower number means higher priority.
}

# Firewall Rule (Internal Traffic): Allows unrestricted internal traffic (both TCP and UDP) within the VPC.
# Ensures that all internal communications across subnets can occur without restriction.
resource "google_compute_firewall" "nw1-internal-allow" {
  name    = "nw1-vpc-internal-allow"
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
  priority      = 1100             # Set a priority slightly lower than the SSH rule.
}

# Firewall Rule (IAP Traffic): Required for IAP access to Google services, including Cloud SQL.
# Allows traffic from Google’s IAP proxy IP range (35.235.240.0/20) to access resources.
resource "google_compute_firewall" "nw1-iap-allow" {
  name    = "nw1-vpc-iap-allow"
  network = google_compute_network.nw1-vpc.id

  # Allow ICMP traffic from Google IAP proxy range.
  allow {
    protocol = "icmp"
  }

  # Allow TCP traffic on all ports from Google IAP proxy range for private access.
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  # Source range for Google IAP traffic.
  source_ranges = ["35.235.240.0/20"] # Specific to Google’s IAP service.
  priority      = 1200                # Set a priority for IAP traffic.
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
