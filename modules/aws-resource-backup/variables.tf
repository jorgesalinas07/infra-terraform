variable "backup_plan_name" {
  type = string
}

variable "backup_rule_name" {
  type = string
}

variable "schedule" {
  type = string
}

variable "aws_backup_selection_name" {
  type = string
}

variable "backup_resource_arn" {
}

variable "backup_vault_name" {
  type = string
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "iam_arns" {
  description = "This variable accepting the ARN of users gives permission to different resources in AWS"
  default = []
}
