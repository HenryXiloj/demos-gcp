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

variable "private_google_access_ips" {
  type    = list(string)
  default = []
}