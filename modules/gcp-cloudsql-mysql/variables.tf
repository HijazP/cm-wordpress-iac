variable "project_id" {
  description = "The project ID to host the database in"
  type        = string
}

variable "name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "The database version to use"
  type        = string
  default     = "MYSQL_8_0"
}

variable "region" {
  description = "The region of the Cloud SQL instance"
  type        = string
}

variable "zone" {
  description = "The zone of the Cloud SQL instance (optional)"
  type        = string
  default     = null
}

variable "tier" {
  description = "The tier for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "The availability type for the master instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "disk_type" {
  description = "The disk type for the master instance"
  type        = string
  default     = "PD_SSD"
}

variable "disk_size" {
  description = "The disk size for the master instance"
  type        = number
  default     = 10
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size automatically"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance"
  type        = bool
  default     = true
}

variable "ip_configuration" {
  description = "The ip configuration for the instance"
  type = object({
    ipv4_enabled                                  = optional(bool)
    private_network                               = optional(string)
    enable_private_path_for_google_cloud_services = optional(bool)
    allocated_ip_range                            = optional(string)
  })
  default = {}
}

variable "backup_configuration" {
  description = "The backup configuration block"
  type = object({
    enabled                        = optional(bool)
    start_time                     = optional(string)
    point_in_time_recovery_enabled = optional(bool)
    transaction_log_retention_days = optional(number)
    retained_backups               = optional(number)
    retention_unit                 = optional(string)
  })
  default = {}
}

variable "maintenance_window_day" {
  description = "The day of week (1-7) for maintenance window"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "The hour of day (0-23) for maintenance window"
  type        = number
  default     = 0
}

variable "maintenance_window_update_track" {
  description = "The update track of maintenance window"
  type        = string
  default     = "stable"
}

variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "additional_databases" {
  description = "A list of additional databases to be created in the instance"
  type = list(object({
    name      = string
    charset   = optional(string)
    collation = optional(string)
  }))
  default = []
}

variable "additional_users" {
  description = "A list of additional users to be created in the instance"
  type = list(object({
    name     = string
    password = string
    host     = optional(string)
    type     = optional(string)
  }))
  default = []
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on"
  type        = list(any)
  default     = []
}

