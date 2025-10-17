# Simplified HTTP Load Balancer Module - All resources defined directly
# No submodules - everything in main.tf

locals {
  health_checked_backends = { for backend_name, backend_config in var.backends : backend_name => backend_config if backend_config.health_check != null }
}

# Backend Service
resource "google_compute_backend_service" "default" {
  for_each = var.backends

  project     = var.project
  name        = "${var.name}-backend-${each.key}"
  description = lookup(each.value, "description", null)
  port_name   = lookup(each.value, "port_name", "http")
  protocol    = lookup(each.value, "protocol", "HTTP")
  timeout_sec = lookup(each.value, "timeout_sec", 10)
  enable_cdn  = lookup(each.value, "enable_cdn", false)

  dynamic "backend" {
    for_each = lookup(each.value, "groups", [])
    content {
      description = lookup(backend.value, "description", null)
      group       = backend.value.group

      balancing_mode               = lookup(backend.value, "balancing_mode", "UTILIZATION")
      capacity_scaler              = lookup(backend.value, "capacity_scaler", 1.0)
      max_connections              = lookup(backend.value, "max_connections", null)
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance", null)
      max_connections_per_endpoint = lookup(backend.value, "max_connections_per_endpoint", null)
      max_rate                     = lookup(backend.value, "max_rate", null)
      max_rate_per_instance        = lookup(backend.value, "max_rate_per_instance", null)
      max_rate_per_endpoint        = lookup(backend.value, "max_rate_per_endpoint", null)
      max_utilization              = lookup(backend.value, "max_utilization", null)
    }
  }

  health_checks = lookup(each.value.health_check, "check_interval_sec", null) != null ? [
    google_compute_health_check.default[each.key].self_link
  ] : null

  dynamic "log_config" {
    for_each = lookup(each.value, "log_config", null) != null && lookup(each.value.log_config, "enable", false) ? [each.value.log_config] : []
    content {
      enable      = lookup(log_config.value, "enable", false)
      sample_rate = lookup(log_config.value, "sample_rate", 1.0)
    }
  }

  connection_draining_timeout_sec = lookup(each.value, "connection_draining_timeout_sec", null)
  session_affinity                = lookup(each.value, "session_affinity", null)
  affinity_cookie_ttl_sec         = lookup(each.value, "affinity_cookie_ttl_sec", null)
}

# Health Check
resource "google_compute_health_check" "default" {
  for_each = local.health_checked_backends

  project = var.project
  name    = "${var.name}-hc-${each.key}"

  check_interval_sec  = lookup(each.value.health_check, "check_interval_sec", 5)
  timeout_sec         = lookup(each.value.health_check, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 2)

  http_health_check {
    port         = lookup(each.value.health_check, "port", 80)
    request_path = lookup(each.value.health_check, "request_path", "/")
    host         = lookup(each.value.health_check, "host", null)
  }

  dynamic "log_config" {
    for_each = lookup(each.value.health_check, "logging", false) ? [1] : []
    content {
      enable = true
    }
  }
}

# Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "default" {
  count = length(var.managed_ssl_certificate_domains) > 0 ? 1 : 0

  project = var.project
  name    = "${var.name}-cert"

  managed {
    domains = var.managed_ssl_certificate_domains
  }
}

# URL Map
resource "google_compute_url_map" "default" {
  project         = var.project
  name            = var.name
  default_service = google_compute_backend_service.default["default"].self_link
}

# URL Map for HTTPS redirect
resource "google_compute_url_map" "https_redirect" {
  count   = var.https_redirect ? 1 : 0
  project = var.project
  name    = "${var.name}-https-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  project = var.project
  name    = "${var.name}-http-proxy"
  url_map = var.https_redirect ? google_compute_url_map.https_redirect[0].self_link : google_compute_url_map.default.self_link
}

# HTTPS Proxy
resource "google_compute_target_https_proxy" "default" {
  count = var.ssl ? 1 : 0

  project = var.project
  name    = "${var.name}-https-proxy"
  url_map = google_compute_url_map.default.self_link

  ssl_certificates = length(var.managed_ssl_certificate_domains) > 0 ? concat(
    [google_compute_managed_ssl_certificate.default[0].self_link],
    var.ssl_certificates
  ) : var.ssl_certificates
}

# Global Forwarding Rule for HTTP
resource "google_compute_global_forwarding_rule" "http" {
  project    = var.project
  name       = var.name
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
  ip_address = var.create_address ? google_compute_global_address.default[0].address : var.address
}

# Global Forwarding Rule for HTTPS
resource "google_compute_global_forwarding_rule" "https" {
  count = var.ssl ? 1 : 0

  project    = var.project
  name       = "${var.name}-https"
  target     = google_compute_target_https_proxy.default[0].self_link
  port_range = "443"
  ip_address = var.create_address ? google_compute_global_address.default[0].address : var.address
}

# Global IP Address
resource "google_compute_global_address" "default" {
  count = var.create_address ? 1 : 0

  project    = var.project
  name       = "${var.name}-address"
  ip_version = "IPV4"
}

# Firewall Rule for Health Checks
resource "google_compute_firewall" "default_hc" {
  count = length(var.firewall_networks) > 0 ? 1 : 0

  project = length(var.firewall_projects) == 1 ? var.firewall_projects[0] : var.project
  name    = "${var.name}-hc"
  network = var.firewall_networks[0]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = length(var.target_tags) > 0 ? var.target_tags : null
}

