
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.31.0"
    }
  }
  backend "s3" {
    bucket  = "primary-tfstates-9442fad89c62895b"
    key     = "infra-terraform/aws-ecr/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

locals {
  repositories = {
    "db_integration_with_fast_api_${terraform.workspace}" = {
      name = "db_integration_with_fast_api_${terraform.workspace}"
    }
  }
}

module "this" {
  for_each             = local.repositories
  source               = "../modules/aws-ecr"
  ecr_name             = each.value.name
  image_tag_mutability = "IMMUTABLE"
}
