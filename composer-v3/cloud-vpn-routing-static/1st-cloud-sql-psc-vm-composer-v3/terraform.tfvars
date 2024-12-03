project_id     = "terraform-workspace-437404"
project_number = "1064430560844"
region         = "us-central1"
zone           = "us-central1-a"

sec_region = "us-west1"
sec_zone   = "us-west1-a"


private_google_access_ips = ["10.10.1.10"]

//common in both project
shared_secret = "hxi123"

project_id_2                                 = "gcp-project1-442623"
destination_range_in_peer_second_GCP_project = "10.20.1.0/24"
static_peer_second_GCP_project_IP            = "34.67.235.208"