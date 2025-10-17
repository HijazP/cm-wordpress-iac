variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "bucket_name" {
  description = "The name of the Cloud Storage bucket"
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
  default     = "ASIA-SOUTHEAST1"
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "lifecycle_delete_after_days" {
  description = "Number of days after which objects are deleted"
  type        = number
  default     = 365
}

variable "cors_origins" {
  description = "List of origins allowed for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "kms_key_name" {
  description = "KMS key name for encryption"
  type        = string
  default     = null
}

variable "public_access_prevention" {
  description = "Public access prevention setting: enforced or unspecified"
  type        = string
  default     = "enforced"
}

variable "log_bucket" {
  description = "The bucket that will receive log objects"
  type        = string
  default     = null
}

variable "log_object_prefix" {
  description = "The object prefix for log objects"
  type        = string
  default     = "wordpress-uploads"
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "service_account_id" {
  description = "The ID of the service account"
  type        = string
  default     = "wordpress-storage-sa"
}

variable "enable_public_read" {
  description = "Enable public read access to uploaded files"
  type        = bool
  default     = false
}
