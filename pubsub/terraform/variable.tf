variable "project_id" {
  default = ""
}

variable "region" {
  default = ""
}

variable "zone" {
  default = ""
}

variable "sec_region" {
  default = ""
}

variable "sec_zone" {
  default = ""
}

variable "shared_secret" {
  default = ""
}

variable "private_google_access_ips" {
  type    = list(string)
  default = []
}

variable "destination_range_in_peer_first_GCP_project" {
  default = ""
}

variable "static_peer_firt_GCP_project_IP" {
  default = ""
}