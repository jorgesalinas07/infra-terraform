terraform {
  required_version = "~> 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.33.0"
    }
  }
  backend "s3" {
    bucket  = "primary-tfstates-9442fad89c62895b"
    key     = "infra-terraform/primary/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

module "tfstate_bucket" {
  source                  = "../modules/aws-s3-bucket"
  bucket_name             = "primary-tfstates"
  bucket_acl              = "private"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

locals {
  region    = "us-east-1"
  vpc_name  = "main-vpc-${terraform.workspace}"
  team_name = "main-devops"
  av_zones = [
    "us-east-1a",
    "us-east-1b"
  ]
  private_subnets_cidr_blocks = [
    "10.10.0.0/22", "10.10.4.0/22"
  ]
  public_subnets_cidr_blocks = [
    "10.10.100.0/24", "10.10.101.0/24" # each subnet will be able to have 254 hosts (enough for LBs and few lambdas)
  ]
}

module "vpc" {
  source = "../modules/aws-base-networking"
  vpc_name                 = local.vpc_name
  availability_zones       = local.av_zones
  vpc_enable_dns_hostnames = true
  vpc_enable_dns_support   = true
  vpc_cidr_block           = "10.10.0.0/16"
  vpc_tags = {
    "team" : local.team_name
  }
  private_subnets_cidr_blocks = local.private_subnets_cidr_blocks
  public_subnets_cidr_blocks  = local.public_subnets_cidr_blocks
  private_subnets_tags = {
    "karpenter.sh/discovery" = local.vpc_name
  }
}
