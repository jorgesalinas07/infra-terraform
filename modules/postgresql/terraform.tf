
terraform {
  required_version = ">= 1.5"
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">=1.21"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.31.0"
    }
  }
}
