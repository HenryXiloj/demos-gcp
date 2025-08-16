#Usage: https://www.educative.io/answers/how-to-create-a-vmvirtual-machine-on-gcp-with-terraform
#Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                            = "terraform-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

#Create a private subnetwork
resource "google_compute_subnetwork" "private_network" {
  name          = "private-network"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.vpc_network.self_link
}

#Create a VPC router
resource "google_compute_router" "router" {
  name    = "quickstart-router"
  network = google_compute_network.vpc_network.self_link
}

#Configure NAT (Network Address Translation)
resource "google_compute_router_nat" "nat" {
  name                               = "quickstart-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

#Create an internet route for private network
resource "google_compute_route" "private_network_internet_route" {
  name             = "private-network-internet"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

#Usage: https://cloud.google.com/iap/docs/using-tcp-forwarding#firewall
# Firewall rule to allow RDP access from Cloud IAP
resource "google_compute_firewall" "allow_rdp_from_iap" {
  name    = "allow-rdp-ingress-from-iap"
  network = google_compute_network.vpc_network.self_link

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# Firewall rule to allow SSH access from Cloud IAP
resource "google_compute_firewall" "allow_ssh_from_iap" {
  name    = "allow-ssh-ingress-from-iap"
  network = google_compute_network.vpc_network.self_link

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}