resource "google_compute_region_instance_group_manager" "mig" {
  project            = var.project_id
  name               = var.mig_name != "" ? var.mig_name : "${var.hostname}-mig"
  base_instance_name = var.hostname
  region             = var.region
  target_size        = var.autoscaling_enabled ? null : var.target_size

  version {
    instance_template = var.instance_template
    name              = "primary"
  }

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  dynamic "update_policy" {
    for_each = var.update_policy
    content {
      type                         = update_policy.value.type
      instance_redistribution_type = lookup(update_policy.value, "instance_redistribution_type", null)
      minimal_action               = update_policy.value.minimal_action
      max_surge_fixed              = lookup(update_policy.value, "max_surge_fixed", null)
      max_surge_percent            = lookup(update_policy.value, "max_surge_percent", null)
      max_unavailable_fixed        = lookup(update_policy.value, "max_unavailable_fixed", null)
      max_unavailable_percent      = lookup(update_policy.value, "max_unavailable_percent", null)
    }
  }

  wait_for_instances        = var.wait_for_instances
  wait_for_instances_status = var.wait_for_instances_status

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaler
resource "google_compute_region_autoscaler" "autoscaler" {
  count = var.autoscaling_enabled ? 1 : 0

  name    = "${var.hostname}-autoscaler"
  project = var.project_id
  region  = var.region
  target  = google_compute_region_instance_group_manager.mig.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    dynamic "cpu_utilization" {
      for_each = var.autoscaling_cpu
      content {
        target            = cpu_utilization.value.target
        predictive_method = lookup(cpu_utilization.value, "predictive_method", null)
      }
    }

    dynamic "metric" {
      for_each = var.autoscaling_metric
      content {
        name   = metric.value.name
        target = metric.value.target
        type   = metric.value.type
      }
    }

    dynamic "load_balancing_utilization" {
      for_each = var.autoscaling_lb
      content {
        target = load_balancing_utilization.value.target
      }
    }

    dynamic "scale_in_control" {
      for_each = var.autoscaling_scale_in_control != null ? [var.autoscaling_scale_in_control] : []
      content {
        max_scaled_in_replicas {
          fixed   = lookup(scale_in_control.value.max_scaled_in_replicas, "fixed", null)
          percent = lookup(scale_in_control.value.max_scaled_in_replicas, "percent", null)
        }
        time_window_sec = lookup(scale_in_control.value, "time_window_sec", null)
      }
    }
  }
}

