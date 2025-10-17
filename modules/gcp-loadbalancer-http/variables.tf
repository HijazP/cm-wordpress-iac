variable "project" {
  description = "The project to deploy to, if not set the default provider project is used"
  type        = string
}

variable "name" {
  description = "Name for the load balancer"
  type        = string
}

variable "backends" {
  description = "Map of backend services"
  type = map(object({
    description                     = optional(string)
    protocol                        = optional(string)
    port_name                       = optional(string)
    timeout_sec                     = optional(number)
    enable_cdn                      = optional(bool)
    compression_mode                = optional(string)
    connection_draining_timeout_sec = optional(number)
    custom_request_headers          = optional(list(string))
    custom_response_headers         = optional(list(string))
    session_affinity                = optional(string)
    affinity_cookie_ttl_sec         = optional(number)

    health_check = object({
      check_interval_sec  = optional(number)
      timeout_sec         = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
      request_path        = optional(string)
      port                = optional(number)
      host                = optional(string)
      logging             = optional(bool)
    })

    log_config = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
    }))

    groups = list(object({
      group                        = string
      balancing_mode               = optional(string)
      capacity_scaler              = optional(number)
      description                  = optional(string)
      max_connections              = optional(number)
      max_connections_per_instance = optional(number)
      max_connections_per_endpoint = optional(number)
      max_rate                     = optional(number)
      max_rate_per_instance        = optional(number)
      max_rate_per_endpoint        = optional(number)
      max_utilization              = optional(number)
    }))

    iap_config = optional(object({
      enable               = bool
      oauth2_client_id     = optional(string)
      oauth2_client_secret = optional(string)
    }))
  }))
}

variable "create_address" {
  description = "Create a new global address"
  type        = bool
  default     = true
}

variable "address" {
  description = "Existing IPv4 address to use (the actual IP address value)"
  type        = string
  default     = null
}

variable "firewall_networks" {
  description = "Names of the networks to create firewall rules in"
  type        = list(string)
  default     = []
}

variable "firewall_projects" {
  description = "Names of the projects to create firewall rules in"
  type        = list(string)
  default     = []
}

variable "target_tags" {
  description = "List of target tags for health check firewall rule"
  type        = list(string)
  default     = []
}

variable "ssl" {
  description = "Set to true to enable SSL support, requires ssl_certificates"
  type        = bool
  default     = false
}

variable "ssl_certificates" {
  description = "SSL certificate URLs to use for HTTPS load balancer"
  type        = list(string)
  default     = []
}

variable "managed_ssl_certificate_domains" {
  description = "Create Google-managed SSL certificates for specified domains"
  type        = list(string)
  default     = []
}

variable "https_redirect" {
  description = "Set to true to enable HTTPS redirect (HTTP traffic redirected to HTTPS)"
  type        = bool
  default     = false
}

