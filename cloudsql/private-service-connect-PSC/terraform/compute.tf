/*
gcloud compute addresses create my-internal-address --project=terraform-workspace-413615 
--region=us-central1 --subnet=nw1-vpc-sub1-us-central1 
--addresses=10.10.1.10
*/
resource "google_compute_address" "internal_address" {
  project      = var.project_id
  name         = "internal-address"
  region       = var.region
  address_type = "INTERNAL"
  address      = "10.10.1.10"                               #"INTERNAL_IP_ADDRESS"
  subnetwork   = google_compute_subnetwork.nw1-subnet1.name #optional
}



