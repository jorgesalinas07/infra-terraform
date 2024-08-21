variable "vpc_cidr_block" {
  description = "CIDR block to be allocated."
  type        = string
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames creation for instances instances with public IP addresses."
  type        = bool
  default     = false
}

variable "vpc_enable_dns_support" {
  description = "Enable VPC DNS resolution via Route53 private zone."
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of this VPC."
  type        = string
}

variable "vpc_tags" {
  description = "List of vpc-specific tags to append to resource"
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets_cidr_blocks" {
  description = "CIDR blocks to be used by public subnets. List length must be equal to availability_zones parameter length."
  type        = list(string)
}

variable "public_subnets_tags" {
  description = "List of tags to append to public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks to be used by private subnets. List length must be equal to availability_zones parameter length."
  type        = list(string)
}

variable "private_subnets_tags" {
  description = "List of tags to append to private subnets"
  type        = map(string)
  default     = {}
}
