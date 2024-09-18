variable "bucket_name" {
  type        = string
  description = "Name for the bucket S3"
}

variable "use_default_kms_key_for_encryption" {
  type        = bool
  description = "This variable creates a KMS key for default"
}
