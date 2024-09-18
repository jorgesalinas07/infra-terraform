terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "aws-terraform-state" {
  source                             = "../"
  bucket_name                        = "terraform-bucket-backups"
  use_default_kms_key_for_encryption = false
}

module "aws-terraform-state-example" {
  source                             = "../"
  bucket_name                        = "terraform-bucket-example-test"
  use_default_kms_key_for_encryption = true
}
