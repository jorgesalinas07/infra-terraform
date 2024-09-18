variable "api_subnet_group" {
  type        = string
  description = "The name of the DB subnet group. If omitted, Terraform will assign a random, unique name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of VPC subnet IDs"
}

variable "api_parameter_group" {
  type        = string
  description = "The name of the DB parameter group to associate with this instance. If omitted, Terraform will associate the default DB parameter group"
}

variable "family_engine" {
  type        = string
  description = "The family of the DB parameter group"
}

variable "api_security_group" {
  type        = string
  description = "The name of the security group to associate with this instance. If omitted, Terraform will assign the default security group"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "from_port_security_group" {
  type        = number
  description = "The start port (or ICMP type number if protocol is \"icmp\")"
}

variable "to_port_security_group" {
  type        = number
  description = "The end port (or ICMP code if protocol is \"icmp\")"
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks"
}

variable "database_identifier" {
  type        = string
  sensitive   = true
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
}

variable "database_name" {
  type        = string
  sensitive   = true
  description = "The name of the database to create on the instance"
}

variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes"
}

variable "engine" {
  type        = string
  description = "The database engine to use"
}

variable "engine_version" {
  type        = string
  description = "The engine version to use for the instance"
}

variable "username" {
  type        = string
  sensitive   = true
  description = "The username for the master DB user"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "The password for the master DB user"
}

variable "publicly_accessible" {
  type        = bool
  description = "Specifies whether the DB instance is publicly accessible"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
}

variable "iam_policy_name" {
  type        = string
  description = "The name of the IAM policy"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
}

variable "account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "iam_user" {
  type        = string
  description = "The name of the IAM user"
}
