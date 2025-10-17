# GCP Cloud Storage Module for WordPress Uploads
# Provides a bucket for storing WordPress media files with proper permissions

resource "google_storage_bucket" "wordpress_uploads" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.location
  force_destroy = var.force_destroy

  # Enable versioning for file history
  versioning {
    enabled = var.versioning_enabled
  }

  # Lifecycle management
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.lifecycle_delete_after_days
    }
  }

  # CORS configuration for web access
  cors {
    origin          = var.cors_origins
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  # Uniform bucket-level access
  uniform_bucket_level_access = true

  # Encryption (optional)
  dynamic "encryption" {
    for_each = var.kms_key_name != null && var.kms_key_name != "" ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  # Public access prevention (configurable)
  public_access_prevention = var.public_access_prevention

  # Logging (optional)
  dynamic "logging" {
    for_each = var.log_bucket != null && var.log_bucket != "" ? [1] : []
    content {
      log_bucket        = var.log_bucket
      log_object_prefix = var.log_object_prefix
    }
  }

  labels = var.labels
}

# Service account for WordPress instances to access the bucket
resource "google_service_account" "wordpress_storage" {
  account_id   = var.service_account_id
  display_name = "WordPress Cloud Storage Access"
  description  = "Service account for WordPress instances to access uploads bucket"
  project      = var.project_id
}

# IAM binding for the service account to access the bucket
resource "google_storage_bucket_iam_member" "wordpress_storage_admin" {
  bucket = google_storage_bucket.wordpress_uploads.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.wordpress_storage.email}"
}

# IAM binding for public read access to uploaded files
resource "google_storage_bucket_iam_member" "public_read" {
  count  = var.enable_public_read && var.public_access_prevention != "enforced" ? 1 : 0
  bucket = google_storage_bucket.wordpress_uploads.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Service account key for authentication
resource "google_service_account_key" "wordpress_storage" {
  service_account_id = google_service_account.wordpress_storage.name
}

# Create a default folder structure
resource "google_storage_bucket_object" "uploads_folder" {
  name    = "uploads/.keep"
  bucket  = google_storage_bucket.wordpress_uploads.name
  content = "placeholder"
}

resource "google_storage_bucket_object" "themes_folder" {
  name    = "themes/.keep"
  bucket  = google_storage_bucket.wordpress_uploads.name
  content = "placeholder"
}

resource "google_storage_bucket_object" "plugins_folder" {
  name    = "plugins/.keep"
  bucket  = google_storage_bucket.wordpress_uploads.name
  content = "placeholder"
}
