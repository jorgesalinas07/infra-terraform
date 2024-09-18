terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
  backend "s3" {
    bucket  = "primary-tfstates-9442fad89c62895b"
    key     = "infra-terraform/aws-tf-states/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  aws_tf_states_bucket_name = "db-int-fapi-states"
}

module "aws_tf_states" {
  source                             = "../modules/aws-terraform-state"
  bucket_name                        = local.aws_tf_states_bucket_name
  use_default_kms_key_for_encryption = false
}
