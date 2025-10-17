output "instance_name" {
  value     = module.mysql.instance_name
}

output "instance_connection_name" {
  value     = module.mysql.instance_connection_name
}

output "instance_self_link" {
  value     = module.mysql.instance_self_link
}

output "private_ip_address" {
  value     = module.mysql.private_ip_address
}

output "db_name" {
  value     = "wordpress"
}

output "db_user" {
  value     = "wp_admin"
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "generated_user_password" {
  value     = module.mysql.generated_user_password
  sensitive = true
}

