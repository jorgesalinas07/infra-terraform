terraform {

  backend "s3" {
    bucket  = ""
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.18.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "${terraform.workspace}"
    }
  }
}

module "vpc" {
  source                      = "../"
  vpc_cidr_block              = "10.10.0.0/16"
  vpc_name                    = "vpc-internal-apps-stg-qa"
  availability_zones          = ["us-east-1a", "us-east-1b"]
  public_subnets_cidr_blocks  = []
  private_subnets_cidr_blocks = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
}
