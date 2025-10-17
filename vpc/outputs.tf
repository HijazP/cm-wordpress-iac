output "network_name" {
  value = module.vpc.network_name
}

output "network_id" {
  value = module.vpc.network_id
}

output "network_self_link" {
  value = module.vpc.network_self_link
}

output "subnets" {
  value = module.vpc.subnets
}

output "subnet_names" {
  value = module.vpc.subnets_names
}

output "subnet_ips" {
  value = module.vpc.subnets_ips
}

output "subnet_regions" {
  value = module.vpc.subnets_regions
}

output "subnet_self_links" {
  value = module.vpc.subnets_self_links
}

output "private_vpc_connection" {
  value = google_service_networking_connection.private_vpc_connection.service
}

output "router_name" {
  value = google_compute_router.router.name
}

output "nat_name" {
  value = google_compute_router_nat.nat.name
}

