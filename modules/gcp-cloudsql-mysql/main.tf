# Simplified Cloud SQL MySQL Module - All resources defined directly
# No submodules - everything in main.tf

resource "google_sql_database_instance" "default" {
  name             = var.name
  project          = var.project_id
  database_version = var.database_version
  region           = var.region
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size
    disk_autoresize   = var.disk_autoresize

    ip_configuration {
      ipv4_enabled                                  = lookup(var.ip_configuration, "ipv4_enabled", false)
      private_network                               = lookup(var.ip_configuration, "private_network", null)
      enable_private_path_for_google_cloud_services = lookup(var.ip_configuration, "enable_private_path_for_google_cloud_services", false)
      allocated_ip_range                            = lookup(var.ip_configuration, "allocated_ip_range", null)
    }

    backup_configuration {
      enabled                        = lookup(var.backup_configuration, "enabled", false)
      start_time                     = lookup(var.backup_configuration, "start_time", null)
      point_in_time_recovery_enabled = lookup(var.backup_configuration, "point_in_time_recovery_enabled", false)
      transaction_log_retention_days = lookup(var.backup_configuration, "transaction_log_retention_days", null)

      backup_retention_settings {
        retained_backups = lookup(var.backup_configuration, "retained_backups", 7)
        retention_unit   = lookup(var.backup_configuration, "retention_unit", "COUNT")
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  depends_on = [var.module_depends_on]

  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }
}

# Additional Databases
resource "google_sql_database" "additional_databases" {
  for_each = { for db in var.additional_databases : db.name => db }

  name      = each.value.name
  project   = var.project_id
  instance  = google_sql_database_instance.default.name
  charset   = lookup(each.value, "charset", null)
  collation = lookup(each.value, "collation", null)
}

# Additional Users
resource "google_sql_user" "additional_users" {
  for_each = { for user in var.additional_users : user.name => user }

  name     = each.value.name
  project  = var.project_id
  instance = google_sql_database_instance.default.name
  host     = lookup(each.value, "host", "%")
  password = each.value.password
  type     = lookup(each.value, "type", "BUILT_IN")
}

