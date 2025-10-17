output "bucket_name" {
  description = "The name of the created bucket"
  value       = google_storage_bucket.wordpress_uploads.name
}

output "bucket_url" {
  description = "The base URL of the bucket"
  value       = google_storage_bucket.wordpress_uploads.url
}

output "bucket_self_link" {
  description = "The URI of the created resource"
  value       = google_storage_bucket.wordpress_uploads.self_link
}

output "service_account_email" {
  description = "The email of the service account"
  value       = google_service_account.wordpress_storage.email
}

output "service_account_key" {
  description = "The private key of the service account"
  value       = google_service_account_key.wordpress_storage.private_key
  sensitive   = true
}

output "uploads_folder_url" {
  description = "The URL of the uploads folder"
  value       = "${google_storage_bucket.wordpress_uploads.url}/uploads"
}
