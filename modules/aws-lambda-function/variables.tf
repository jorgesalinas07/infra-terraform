variable "tags" {
  type        = map(string)
  description = "tags"
  default     = {}
}

variable "name" {
  type        = string
  description = "Lambda function name"
}

variable "environment" {
  type        = string
  description = "env: qa, stage or prod"
}

variable "image_uri" {
  type        = string
  description = "ECR image URI"
  default     = null

}

variable "source_archive_path" {
  type        = string
  description = "Path to the source code"
}

variable "package_type" {
  type    = string
  default = "Zip"
}

variable "runtime" {
  type        = string
  default     = null
  description = "runtime lambda function: golang, python, node, etc"
}

variable "handler" {
  type        = string
  description = "path to the root executable file"
}

variable "command" {
  type        = list(string)
  description = "overrides container command value"
  default     = []
}

variable "entry_point" {
  type        = list(string)
  description = "overrides container entry_point value"
  default     = []
}

variable "working_directory" {
  type        = string
  description = "overrides container working_directory value"
  default     = null
}

variable "timeout_seconds" {
  type        = number
  description = "function execution timeout in seconds. Defaults to 3, the lambda default"
  default     = 3
}

variable "memory_size_mb" {
  type        = number
  description = "fucntion memory limit. Defaults to 128, the lambda default value"
  default     = 128
}

variable "logs_retention_in_days" {
  type        = number
  description = "Number of days for which cloudwatch logs should retain build logs. Defaults to 365"
  default     = 365
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to be passed in"
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the lambda function"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs associated with the lambda function"
  default     = []
}

variable "execution_role_data" {
  type = object({
    name = string
    arn  = string
  })
  description = "Lambda execution IAM role name and arn"
  default     = null
}