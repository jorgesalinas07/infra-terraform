variable "ecr_name" {
  type        = string
  description = "The name of the repository"
}

variable "tags" {
  type        = map(string)
  description = "tags"
  default     = {}
}

variable "image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
  description = "The tag mutability setting for the repository"
}

variable "count_number" {
  type        = number
  default     = 5
  description = "The number of images to keep in the repository"
}
