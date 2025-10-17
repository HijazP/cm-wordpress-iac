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
    prefix = "compute/terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Reserve a global static IP for the HTTP(S) Load Balancer so the IP stays constant
resource "google_compute_global_address" "lb_ip" {
  name       = "wp-prod-http-lb-address"
  project    = var.gcp_project_id
  ip_version = "IPV4"

  lifecycle {
    prevent_destroy = true
  }
}

# Read Cloud SQL outputs from its remote state so credentials stay in sync
data "terraform_remote_state" "cloud_sql" {
  backend = "gcs"
  config = {
    bucket = "bucket-tfstate-cm-test"
    prefix = "cloud-sql/terraform/state"
  }
}

# Cloud Storage module for WordPress uploads
module "wordpress_storage" {
  source = "../modules/gcp-cloud-storage"

  project_id   = var.gcp_project_id
  bucket_name  = var.storage_bucket_name
  location     = var.gcp_region
  labels = {
    environment = "production"
    application = "wordpress"
    managed_by  = "terraform"
  }
}

# Instance template for WordPress
resource "google_compute_instance_template" "wordpress_template" {
  name_prefix  = "wp-prod-vm-template-"
  project      = var.gcp_project_id
  machine_type = "e2-medium"
  region       = var.gcp_region

  lifecycle {
    create_before_destroy = true
  }

  disk {
    source_image = "cos-cloud/cos-125-19216-0-87"
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      
      # Start WordPress container and configure WP-Stateless via WORDPRESS_CONFIG_EXTRA
      docker run -d -p 80:80 \
      -e WORDPRESS_DB_HOST=${data.terraform_remote_state.cloud_sql.outputs.private_ip_address} \
      -e WORDPRESS_DB_USER=${data.terraform_remote_state.cloud_sql.outputs.db_user} \
      -e WORDPRESS_DB_PASSWORD=${data.terraform_remote_state.cloud_sql.outputs.db_password} \
      -e WORDPRESS_DB_NAME=${data.terraform_remote_state.cloud_sql.outputs.db_name} \
      -e WP_STATELESS_MEDIA_BUCKET=${var.storage_bucket_name} \
      -e WP_STATELESS_MEDIA_MODE=${var.wp_stateless_mode} \
      -e WP_STATELESS_MEDIA_ROOT_DIR=${var.wp_stateless_root_dir} \
      -e WORDPRESS_CONFIG_EXTRA="define('WP_STATELESS_MEDIA_BUCKET', getenv('WP_STATELESS_MEDIA_BUCKET'));
      define('WP_STATELESS_MEDIA_MODE', getenv('WP_STATELESS_MEDIA_MODE'));
      define('WP_STATELESS_MEDIA_ROOT_DIR', getenv('WP_STATELESS_MEDIA_ROOT_DIR'));" \
      --name wordpress \
      ${var.container_image}

      # Wait for WordPress readiness using short-lived wordpress:cli container
      for i in {1..30}; do
        if docker run --rm --network container:wordpress --volumes-from wordpress wordpress:cli \
          wp core is-installed --allow-root --path=/var/www/html; then
          break
        fi
        sleep 5
      done

      # Activate all plugins using wordpress:cli against the running container
      docker run --rm --network container:wordpress --volumes-from wordpress wordpress:cli \
        wp plugin activate --all --allow-root --path=/var/www/html || true
    EOT
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = ["wp-prod-vm", "http-server"]
}

module "mig" {
  source = "../modules/gcp-compute-mig"

  project_id        = var.gcp_project_id
  region            = var.gcp_region
  target_size       = 1
  hostname          = "wp-prod-vm"
  instance_template = google_compute_instance_template.wordpress_template.self_link
  
  named_ports = [{
    name = "http"
    port = 80
  }]

  update_policy = [{
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 3
    max_unavailable_fixed        = 0
  }]

  autoscaling_enabled = true
  max_replicas        = 2
  min_replicas        = 1
  cooldown_period     = 60
  
  autoscaling_cpu = [{
    target = 0.8
  }]
}

# Health check for load balancer
resource "google_compute_health_check" "http_health_check" {
  name               = "wp-prod-http-healthcheck"
  project            = var.gcp_project_id
  check_interval_sec = 10
  timeout_sec        = 5
  
  http_health_check {
    port         = 80
    request_path = "/license.txt"
  }
}

module "lb_http" {
  source = "../modules/gcp-loadbalancer-http"

  project = var.gcp_project_id
  name    = "wp-prod-http-lb"

  # Enable HTTPS with managed SSL certificate
  ssl                             = true
  managed_ssl_certificate_domains = ["cm.hanifalir.me"]
  https_redirect                  = true

  firewall_networks = [var.network_name]
  firewall_projects = [var.gcp_project_id]
  target_tags       = ["wp-prod-vm"]

  # Use the reserved static IP; disable module-managed address creation
  create_address = false
  address        = google_compute_global_address.lb_ip.address

  backends = {
    default = {
      description                     = "WordPress backend service"
      protocol                        = "HTTP"
      port_name                       = "http"
      timeout_sec                     = 30
      enable_cdn                      = false
      compression_mode                = "DISABLED"
      connection_draining_timeout_sec = 300
      custom_request_headers          = null
      custom_response_headers         = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = 10
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        request_path        = "/license.txt"
        port                = 80
        host                = null
        logging             = false
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = 1.0
          description                  = "WordPress MIG"
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}

