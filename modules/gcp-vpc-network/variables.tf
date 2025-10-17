variable "project_id" {
  description = "The project ID to host the network in"
  type        = string
}

variable "network_name" {
  description = "The name of the network being created"
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
}

variable "delete_default_internet_gateway_routes" {
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  type        = bool
  default     = false
}

variable "mtu" {
  description = "The network MTU (default is 0, which means GCP will use 1460 for non-jumbo and 8896 for jumbo frames)"
  type        = number
  default     = 0
}

variable "subnets" {
  description = "The list of subnets being created"
  type = list(object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = string
    subnet_private_access = optional(string)
  }))
  default = []
}

variable "secondary_ranges" {
  description = "Secondary ranges that will be used in some of the subnets"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {}
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name                    = string
    description             = optional(string)
    direction               = optional(string)
    priority                = optional(number)
    ranges                  = optional(list(string))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
  }))
  default = []
}

variable "routes" {
  description = "List of routes being created in this VPC"
  type = list(object({
    name              = string
    description       = optional(string)
    destination_range = string
    tags              = optional(string)
    next_hop_internet = optional(string)
    next_hop_ip       = optional(string)
    priority          = optional(number)
  }))
  default = []
}

