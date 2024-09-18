

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
  backend "s3" {
    bucket  = "ioet-primary-tfstates-eb4b4dac1df7f095"
    key     = "infra-terraform-modules/ioet-primary/aws-postgresql/examples/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

######################################################################
# DB Credentials should be provided via AWS Secrets Manager
######################################################################

data "external" "root_sops_secrets" {
  program = ["sops", "--decrypt", "root_db_user.sops.json"]
}

data "external" "gitea_sops_secrets" {
  program = ["sops", "--decrypt", "gitea_db_user.sops.json"]
}

module "root_secrets_manager" {
  source = "../../aws-secret-manager"
  name   = "devops/rds/postgres/prod/root"
  data   = data.external.root_sops_secrets.result
}

module "gitea_secrets_manager" {
  source = "../../aws-secret-manager"
  name   = "devops/rds/postgres/prod/gitea"
  data   = data.external.gitea_sops_secrets.result
}

######################################################################
# Additional Data required for creating an RDS Instance
######################################################################

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["ioet-primary"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = [for suffix in ["a-0", "b-1", "c-2"] : "ioet-primary-public-us-east-1${suffix}"]
  }
}

locals {
  postgres_major_version = "16"
  postgres_minor_version = "1"
  engine_family          = "postgres${local.postgres_major_version}"
  postgres_version       = "${local.postgres_major_version}.${local.postgres_minor_version}"
  service_name           = "maindb"
  environment            = "prod"
  aws_region             = "us-east-1"
  allowed_cidr_blocks    = ["0.0.0.0/0"]
  instance_size          = "db.t3.medium"
  disk_size              = 5 # GB
  public_instance        = true
}

######################################################################
# Additional Data required for Postgres Objects within the Instance
######################################################################

data "aws_secretsmanager_secret_version" "root_user_secret" {
  secret_id = module.root_secrets_manager.secrets_manager_version.arn
}

data "local_file" "postgres_databases" {
  filename = "databases.csv"
}

data "local_file" "postgres_schemas" {
  filename = "schemas.csv"
}

data "local_file" "postgres_roles" {
  filename = "roles.csv"
}

locals {
  postgres_databases = csvdecode(data.local_file.postgres_databases.content)
  postgres_schemas   = csvdecode(data.local_file.postgres_schemas.content)
  postgres_roles     = csvdecode(data.local_file.postgres_roles.content)
}

######################################################################
# Creating the actual database
######################################################################

provider "postgresql" {
  scheme    = "awspostgres"
  host      = module.postgres_rds.rds.db_instance.address
  port      = 5432
  database  = "postgres"
  username  = jsondecode(data.aws_secretsmanager_secret_version.root_user_secret.secret_string)["username"]
  password  = jsondecode(data.aws_secretsmanager_secret_version.root_user_secret.secret_string)["password"]
  sslmode   = "require"
  superuser = false
  #  clientcert {
  #    cert = "/path/to/public-certificate.pem"
  #    key  = "/path/to/private-key.pem"
  #  }
}

module "postgres_rds" {
  depends_on = [
    module.root_secrets_manager,
    module.gitea_secrets_manager # roles.csv should be updated with the ARN of the created secrets manager
  ]
  source                  = "../"
  aws_secret_manager_name = module.root_secrets_manager.secrets_manager.name
  vpc_id                  = data.aws_vpc.selected.id
  subnet_ids              = data.aws_subnets.private.ids
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

module "postgres_config" {
  depends_on = [
    module.postgres_rds
  ]
  source             = "../../postgresql"
  postgres_databases = { for row in local.postgres_databases : row.name => row }
  postgres_schemas   = { for row in local.postgres_schemas : row.name => row }
  postgres_roles     = { for row in local.postgres_roles : row.name => row }
}
