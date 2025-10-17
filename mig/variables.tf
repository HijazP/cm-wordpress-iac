variable "gcp_project_id" {
  type      = string
  default   = "ascendant-ridge-421316"
}

variable "gcp_region" {
  type      = string
  default   = "asia-southeast1"
}

variable "gcp_zone" {
  type      = string
  default   = "asia-southeast1-a"
}

variable "network_name" {
  type      = string
  default   = "wp-prod-vpc-network"
}

variable "subnetwork_name" {
  type      = string
  default   = "wp-prod-subnet-main"
}

variable "db_host" {
  type      = string
  default   = "10.10.0.3"
}

variable "db_user" {
  type      = string
  default   = "wp_admin"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "wp_password"
}

variable "db_name" {
  type      = string
  default   = "wordpress"
}

variable "storage_bucket_name" {
  type      = string
  default   = "wp-prod-uploads-bucket"
}

variable "wp_stateless_mode" {
  type      = string
  default   = "stateless"
}

variable "wp_stateless_root_dir" {
  type      = string
  default   = "uploads"
}

variable "container_image" {
  type      = string
  default   = "wordpress:latest"
}

