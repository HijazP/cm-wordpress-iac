output "backend_services" {
  description = "The backend service resources"
  value       = google_compute_backend_service.default
}

output "external_ip" {
  description = "The external IPv4 assigned to the global fowarding rule"
  value       = google_compute_global_forwarding_rule.http.ip_address
}

output "http_proxy" {
  description = "The HTTP proxy used by this module"
  value       = google_compute_target_http_proxy.default.self_link
}

output "https_proxy" {
  description = "The HTTPS proxy used by this module"
  value       = var.ssl ? google_compute_target_https_proxy.default[0].self_link : null
}

output "url_map" {
  description = "The default URL map used by this module"
  value       = google_compute_url_map.default.self_link
}

output "ssl_certificate_id" {
  description = "The ID of the managed SSL certificate"
  value       = length(var.managed_ssl_certificate_domains) > 0 ? google_compute_managed_ssl_certificate.default[0].certificate_id : null
}

