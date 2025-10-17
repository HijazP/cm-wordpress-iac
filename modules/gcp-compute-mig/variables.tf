variable "project_id" {
  description = "The GCP project to use for integration tests"
  type        = string
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
}

variable "hostname" {
  description = "Hostname prefix for instances"
  type        = string
  default     = "default"
}

variable "mig_name" {
  description = "Managed instance group name. If empty, the value will be derived from var.hostname"
  type        = string
  default     = ""
}

variable "instance_template" {
  description = "Instance template self link used to create compute instances"
  type        = string
}

variable "target_size" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless autoscaling is enabled"
  type        = number
  default     = 1
}

variable "named_ports" {
  description = "Named name and named port"
  type = list(object({
    name = string
    port = number
  }))
  default = []
}

variable "update_policy" {
  description = "The update policy for this managed instance group"
  type = list(object({
    type                         = string
    instance_redistribution_type = optional(string)
    minimal_action               = string
    max_surge_fixed              = optional(number)
    max_surge_percent            = optional(number)
    max_unavailable_fixed        = optional(number)
    max_unavailable_percent      = optional(number)
  }))
  default = []
}

variable "wait_for_instances" {
  description = "Whether to wait for all instances to be created/updated before returning"
  type        = bool
  default     = false
}

variable "wait_for_instances_status" {
  description = "When used with wait_for_instances it specifies the status to wait for"
  type        = string
  default     = "STABLE"
}

variable "autoscaling_enabled" {
  description = "Creates an autoscaler for the managed instance group"
  type        = bool
  default     = false
}

variable "max_replicas" {
  description = "The maximum number of instances that the autoscaler can scale up to"
  type        = number
  default     = 10
}

variable "min_replicas" {
  description = "The minimum number of replicas that the autoscaler can scale down to"
  type        = number
  default     = 2
}

variable "cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information"
  type        = number
  default     = 60
}

variable "autoscaling_cpu" {
  description = "Autoscaling based on cpu utilization"
  type = list(object({
    target            = number
    predictive_method = optional(string)
  }))
  default = []
}

variable "autoscaling_metric" {
  description = "Autoscaling based on metrics"
  type = list(object({
    name   = string
    target = number
    type   = string
  }))
  default = []
}

variable "autoscaling_lb" {
  description = "Autoscaling based on load balancer utilization"
  type = list(object({
    target = number
  }))
  default = []
}

variable "autoscaling_scale_in_control" {
  description = "Autoscaling scale in control"
  type = object({
    max_scaled_in_replicas = object({
      fixed   = optional(number)
      percent = optional(number)
    })
    time_window_sec = optional(number)
  })
  default = null
}

