variable "gcp_project_id" {
  type    = string
  default = "ascendant-ridge-421316"
}

variable "gcp_region" {
  type    = string
  default = "asia-southeast1"
}

variable "gcp_zone" {
  type    = string
  default = "asia-southeast1-a"
}

variable "network_name" {
  type    = string
  default = "wp-prod-vpc-network"
}

variable "private_vpc_connection" {
  type    = string
  default = "servicenetworking.googleapis.com"
}

