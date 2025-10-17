output "instance" {
  description = "The Cloud SQL instance"
  value       = google_sql_database_instance.default
  sensitive   = true
}

output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.default.name
}

output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.default.connection_name
}

output "instance_self_link" {
  description = "The URI of the Cloud SQL instance"
  value       = google_sql_database_instance.default.self_link
}

output "instance_first_ip_address" {
  description = "The first IPv4 address of the addresses assigned"
  value       = google_sql_database_instance.default.first_ip_address
}

output "private_ip_address" {
  description = "The first private (PRIVATE) IPv4 address assigned"
  value       = google_sql_database_instance.default.private_ip_address
}

output "public_ip_address" {
  description = "The first public (PRIMARY) IPv4 address assigned"
  value       = google_sql_database_instance.default.public_ip_address
}

output "generated_user_password" {
  description = "The auto generated default user password if not input password was provided"
  value       = ""
  sensitive   = true
}

output "additional_users" {
  description = "List of additional users"
  value       = google_sql_user.additional_users
  sensitive   = true
}

