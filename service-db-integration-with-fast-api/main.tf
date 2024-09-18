terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.31.0"
    }
  }
  backend "s3" {
    bucket  = "primary-tfstates-9442fad89c62895b"
    key     = "infra-terraform/service-db-integration-with-fast-api/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


locals {
  tfenv_file   = "${path.module}/config/${local.environment}.json"
  tfenv        = jsondecode(file(local.tfenv_file))
  secrets_file = "${path.module}/secrets/${local.environment}.json"
  tfsecretsenv = jsondecode(file(local.secrets_file))
}

locals {
  environment            = terraform.workspace
  postgres_major_version = local.tfenv.postgres.version.major
  postgres_minor_version = local.tfenv.postgres.version.minor
  engine_family          = "postgres${local.postgres_major_version}"
  postgres_version       = "${local.postgres_major_version}.${local.postgres_minor_version}"
  service_name           = "maindb"
  aws_region             = local.tfenv.aws.region
  allowed_cidr_blocks    = local.tfenv.postgres.allowed_cidr_blocks
  instance_size          = local.tfenv.postgres.instance_size
  disk_size              = local.tfenv.postgres.disk_size
  public_instance        = local.tfenv.postgres.public
}

module "secrets_manager" {
  source = "../modules/aws-secret-manager"
  name   = "devops/rds/postgres/${local.environment}/root"
  data   = local.tfsecretsenv
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc-${terraform.workspace}"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = [for suffix in ["a-0", "b-1"] : "main-vpc-${terraform.workspace}-private-us-east-1${suffix}"]
  }
}
locals {
  service_identifier = "maindb-${terraform.workspace}-${local.aws_region}"
}

module "postgres_rds" {
  depends_on = [
    module.secrets_manager,
  ]
  source = "../modules/aws-postgresql"
  aws_secret_manager_name = module.secrets_manager.secrets_manager.name
  vpc_id = data.aws_vpc.selected.id
  subnet_ids         = [for subnet in data.aws_subnets.private.ids : subnet]
  engine_family           = local.engine_family
  postgres_version        = local.postgres_version
  service_name            = local.service_name
  environment             = local.environment
  aws_region              = local.aws_region
  allowed_cidr_blocks     = local.allowed_cidr_blocks
  instance_size           = local.instance_size
  disk_size               = local.disk_size
  publicly_accessible     = local.public_instance
}
