terraform {
  required_version = "~> 1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "external" "sops_secrets" {
  program = ["sops", "--decrypt", "secrets.sops.json"]
}

resource "random_password" "secret_key" {
  length  = 32
  special = true
}

module "secrets_manager" {
  source = "../"
  name   = "secret-name"
  data   = merge(data.external.sops_secrets.result, { SESSION_SECRET = "${random_password.secret_key.result}" })
}
