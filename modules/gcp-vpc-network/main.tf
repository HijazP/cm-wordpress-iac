# Simplified VPC Network Module - All resources defined directly
# No submodules - everything in main.tf

# VPC Network
resource "google_compute_network" "network" {
  name                            = var.network_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  project                         = var.project_id
  delete_default_routes_on_create = var.delete_default_internet_gateway_routes
  mtu                             = var.mtu
}

# Subnets
resource "google_compute_subnetwork" "subnetwork" {
  for_each = { for subnet in var.subnets : subnet.subnet_name => subnet }

  name                     = each.value.subnet_name
  ip_cidr_range            = each.value.subnet_ip
  region                   = each.value.subnet_region
  private_ip_google_access = lookup(each.value, "subnet_private_access", "false")
  
  dynamic "secondary_ip_range" {
    for_each = lookup(var.secondary_ranges, each.value.subnet_name, [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  network = google_compute_network.network.name
  project = var.project_id
}

# Firewall Rules
resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name                    = each.value.name
  description             = lookup(each.value, "description", null)
  direction               = lookup(each.value, "direction", "INGRESS")
  network                 = google_compute_network.network.name
  project                 = var.project_id
  source_ranges           = lookup(each.value, "direction", "INGRESS") == "INGRESS" ? lookup(each.value, "ranges", []) : null
  destination_ranges      = lookup(each.value, "direction", "INGRESS") == "EGRESS" ? lookup(each.value, "ranges", []) : null
  source_tags             = lookup(each.value, "source_tags", null)
  source_service_accounts = lookup(each.value, "source_service_accounts", null)
  target_tags             = lookup(each.value, "target_tags", null)
  target_service_accounts = lookup(each.value, "target_service_accounts", null)
  priority                = lookup(each.value, "priority", 1000)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", null) != null ? each.value.allow : []
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", null) != null ? each.value.deny : []
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }

  depends_on = [google_compute_network.network]
}

# Routes (if needed)
resource "google_compute_route" "route" {
  for_each = { for route in var.routes : route.name => route }

  project          = var.project_id
  network          = google_compute_network.network.name
  name             = each.value.name
  description      = lookup(each.value, "description", null)
  tags             = compact(split(",", lookup(each.value, "tags", "")))
  dest_range       = each.value.destination_range
  next_hop_gateway = lookup(each.value, "next_hop_internet", "false") == "true" ? "default-internet-gateway" : null
  next_hop_ip      = lookup(each.value, "next_hop_ip", null)
  priority         = lookup(each.value, "priority", 1000)

  depends_on = [google_compute_subnetwork.subnetwork]
}

