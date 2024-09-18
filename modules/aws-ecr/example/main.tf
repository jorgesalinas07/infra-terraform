terraform {

  backend "s3" {
    bucket  = "app-tfstate"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}

module "ecr_people_repository" {
  source   = "../"
  ecr_name = "aws_ecr_people_api"
  tags = {
    Name = "aws_ecr_people_api"
  }
}
