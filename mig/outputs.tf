output "instance_template_name" {
  value = google_compute_instance_template.wordpress_template.name
}

output "instance_template_self_link" {
  value = google_compute_instance_template.wordpress_template.self_link
}

output "mig_instance_group" {
  value = module.mig.instance_group
}

output "mig_self_link" {
  value = module.mig.self_link
}

output "load_balancer_ip" {
  value = module.lb_http.external_ip
}

output "load_balancer_backend_services" {
  value = module.lb_http.backend_services
}

output "ssl_certificate_id" {
  value = module.lb_http.ssl_certificate_id
}

output "https_proxy" {
  value = module.lb_http.https_proxy
}

output "storage_bucket_name" {
  value = module.wordpress_storage.bucket_name
}

output "storage_bucket_url" {
  value = module.wordpress_storage.bucket_url
}

output "uploads_folder_url" {
  value = module.wordpress_storage.uploads_folder_url
}

