variable "project_id" {
  default = ""
}

variable "project_number" {
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

variable "project_id_2" {
  default = ""
}

variable "private_google_access_ips" {
  type    = list(string)
  default = []
}

variable "destination_range_in_peer_second_GCP_project" {
  default = ""
}

variable "static_peer_second_GCP_project_IP" {
  default = ""
}