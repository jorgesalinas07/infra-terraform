terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
  backend "s3" {
    bucket = "bucket_example-30d16de28edcf6e0"
    key    = "example_folder.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "bucket_example" {
  source                  = "../"
  bucket_name             = "bucket-example"
  bucket_acl              = "public-read"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

module "bucket_example_two" {
  source                  = "../"
  bucket_name             = "bucket-example-two"
  bucket_acl              = "public-read"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
