
variable "aws_secret_manager_name" {
  description = "Name of the AWS Secret Manager that stores root user credentials for RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS Instance will be provisioned"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where the RDS Instance is allowed to be provisioned"
  type        = list(string)
}

variable "engine_family" {
  description = "Engine Family to be passed to RDS"
  type        = string
  validation {
    condition     = substr(var.engine_family, 0, 8) == "postgres"
    error_message = "Engine Family must start with 'postgres'."
  }
}

variable "postgres_version" {
  description = "PostgreSQL Version (major.minor) to be used"
  type        = string
}

variable "service_name" {
  description = "Service Name with which associated resources should be named and tagged"
  type        = string
}

variable "environment" {
  description = "The environment that this is deployed to"
  type        = string
}

variable "aws_region" {
  description = "The aws region identifier where this should be deployed"
  type        = string
}


variable "allowed_cidr_blocks" {
  description = "List of CIDR Blocks allowed to connect to the database"
  type        = list(string)
}


variable "instance_size" {
  description = "Size of the RDS Instance"
  type        = string
}

variable "disk_size" {
  description = "Disk Size in GB, default: 5 GB"
  type        = number
  default     = 5
}

variable "publicly_accessible" {
  description = "Should this database be publicly accessible? Default: false (database instance is private)"
  type        = bool
  default     = false
}
