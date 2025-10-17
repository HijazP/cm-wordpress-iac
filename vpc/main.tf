terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "bucket-tfstate-cm-test"
    prefix = "vpc/terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "vpc" {
  source = "../modules/gcp-vpc-network"

  project_id   = var.gcp_project_id
  network_name = "wp-prod-vpc-network"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "wp-prod-subnet-main"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = var.gcp_region
      subnet_private_access = "true"
    }
  ]

  firewall_rules = [
    {
      name        = "wp-prod-allow-http-https-healthcheck"
      description = "Allow HTTP, HTTPS and health check traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["130.211.0.0/22", "35.191.0.0/16", "0.0.0.0/0"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
    },
    {
      name        = "wp-prod-allow-ssh-iap"
      description = "Allow SSH via Identity-Aware Proxy"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["35.235.240.0/20"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  ]
}

# Private IP address range for VPC peering with Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "wp-prod-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  address       = "10.10.0.0"
  network       = module.vpc.network_id
}

# VPC peering connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud Router for Cloud NAT
resource "google_compute_router" "router" {
  name    = "wp-prod-router"
  project = var.gcp_project_id
  region  = var.gcp_region
  network = module.vpc.network_id

  bgp {
    asn = 64514
  }
}

# Cloud NAT for internet access from private instances
resource "google_compute_router_nat" "nat" {
  name                               = "wp-prod-nat"
  project                            = var.gcp_project_id
  router                             = google_compute_router.router.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

