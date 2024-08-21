
variable "name" {
  type        = string
  description = "Secrets Manager Name"
}

variable "data" {
  type        = map(any)
  description = "JSON Data for Secrets Manager"
  sensitive   = true
}
