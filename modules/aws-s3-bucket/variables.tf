
variable "bucket_name" {
  type = string
}

variable "bucket_acl" {
  type        = string
  description = "You can put a different ACL for example private, public-read, public-read-write, aws-exec-read, authenticated-read, and log-delivery-write"
  validation {
    condition     = contains(["private", "public-read", "public-read-write", " aws-exec-read", "authenticated-read", "log-delivery-write"], var.bucket_acl)
    error_message = "Invalid input, options: \"private\", \"public-read\", \"public-read-write\" \"aws-exec-read\", \"authenticated-read\", \"log-delivery-write\"."
  }
}

variable "block_public_acls" {
  type        = bool
  description = "You can put True or False to block the public acls in the bucket"
  validation {
    condition     = contains([true, false], var.block_public_acls)
    error_message = "Invalid input, options: \"true\", \"false\"."
  }
}
variable "block_public_policy" {
  type        = bool
  description = "You can put True or False to block the public policy in the bucket"
  validation {
    condition     = contains([true, false], var.block_public_policy)
    error_message = "Invalid input, options: \"true\", \"false\"."
  }
}
variable "ignore_public_acls" {
  type        = bool
  description = "You can put True or False to ignore the public acls in the bucket"
  validation {
    condition     = contains([true, false], var.ignore_public_acls)
    error_message = "Invalid input, options: \"true\", \"false\"."
  }
}
variable "restrict_public_buckets" {
  type        = bool
  description = "You can put True or False to restrict the public buckets"
  validation {
    condition     = contains([true, false], var.restrict_public_buckets)
    error_message = "Invalid input, options: \"true\", \"false\"."
  }
}
