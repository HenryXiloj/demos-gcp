project_id = "gcp-project1-442623"
region     = "us-central1"
zone       = "us-central1-a"

sec_region    = "us-west1"
sec_zone      = "us-west1-a"

private_google_access_ips = ["10.20.1.10"]


//common in both project for vpn_tunnel 
shared_secret = "hxi123"

destination_range_in_peer_first_GCP_project = "10.10.1.0/24"
static_peer_firt_GCP_project_IP            = "34.57.163.111"