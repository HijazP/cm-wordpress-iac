output "network" {
  description = "The VPC resource being created"
  value       = google_compute_network.network
}

output "network_name" {
  description = "The name of the VPC being created"
  value       = google_compute_network.network.name
}

output "network_id" {
  description = "The ID of the VPC being created"
  value       = google_compute_network.network.id
}

output "network_self_link" {
  description = "The URI of the VPC being created"
  value       = google_compute_network.network.self_link
}

output "subnets" {
  description = "The created subnet resources"
  value       = google_compute_subnetwork.subnetwork
}

output "subnets_names" {
  description = "The names of the subnets being created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.name]
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.ip_cidr_range]
}

output "subnets_regions" {
  description = "The region where the subnets will be created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.region]
}

output "subnets_self_links" {
  description = "The self-links of subnets being created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.self_link]
}

