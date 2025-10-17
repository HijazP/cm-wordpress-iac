terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "gcs" {
    bucket = "bucket-tfstate-cm-test"
    prefix = "cloud-sql/terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = false
}

module "mysql" {
  source = "../modules/gcp-cloudsql-mysql"

  name                = "wp-prod-mysql-instance"
  project_id          = var.gcp_project_id
  database_version    = "MYSQL_8_0"
  region              = var.gcp_region
  zone                = var.gcp_zone
  tier                = "db-f1-micro"
  deletion_protection = false

  ip_configuration = {
    ipv4_enabled                                  = false
    private_network                               = "projects/${var.gcp_project_id}/global/networks/${var.network_name}"
    enable_private_path_for_google_cloud_services = true
    require_ssl                                   = false
    allocated_ip_range                            = null
  }

  backup_configuration = {
    enabled                        = true
    start_time                     = "02:00"
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 7
    retention_unit                 = "COUNT"
  }

  maintenance_window_day          = 6
  maintenance_window_hour         = 19
  maintenance_window_update_track = "stable"

  database_flags = []

  additional_databases = [
    {
      name      = "wordpress"
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  ]

  additional_users = [
    {
      name     = "wp_admin"
      password = random_password.db_password.result
      host     = "%"
      type     = "BUILT_IN"
    }
  ]

  module_depends_on = [var.private_vpc_connection]
}

