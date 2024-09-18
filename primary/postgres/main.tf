terraform {
  required_version = "~> 1.5.7"
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
    bucket  = "primary-tfstates-2ab7ffd963729f52"
    key     = "infra-terraform/primary/postgres/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# provider "aws" {
#   region = "us-east-1"
# }
# # New project, nbew VPC? Ask Manuel
# locals {
#   vpc_name  = "main-vpc"
#   environment        = terraform.workspace
#   tfenv_file         = "${path.module}/config/${local.environment}.json"
#   tfenv              = jsondecode(file(local.tfenv_file))
#   secrets_index_file = "${path.module}/secrets/${local.environment}/index.csv"
#   secrets_index = {
#     for secret in csvdecode(file(local.secrets_index_file)) :
#     "${secret.environment}/${secret.app}" => merge(secret, {
#       name_override = secret.name_override == "" ? (
#         local.environment == secret.environment ? secret.app : "${secret.environment}/${secret.app}"
#       ) : secret.name_override
#     })
#   }
#   secrets_environments = toset([for k, v in local.secrets_index : v.environment])
#   secrets_apps         = toset([for k, v in local.secrets_index : v.app])
#   secrets_ids          = toset([for k, v in local.secrets_index : k])
# }

# ######################################################################
# # DB Credentials should be provided via AWS Secrets Manager
# ######################################################################

# # data "external" "secrets" {
# #   for_each = local.secrets_index
# #   program  = ["${path.module}/secrets/${local.environment}/${each.value.file}"]
# # }

# # locals {
# #   secrets = jsondecode(file("${path.module}/secrets/${local.environment}/${each.value.file}"))
# # }

# module "secrets_manager" {
#   for_each = local.secrets_index
#   # source   = "git@github.com:ioet/infra-terraform-modules.git//aws-secret-manager?ref=v0.0.56"
#   # source = "../modules/aws-secret-manager"
#   source = "../../modules/aws-secret-manager"
#   name     = "devops/rds/postgres/${local.environment}/${each.value.name_override}"
#   # data     = data.external.secrets[each.key].result
#   data = jsondecode(file("${path.module}/secrets/${local.environment}/${each.value.file}"))
# }

# # ######################################################################
# # # Additional Data required for creating an RDS Instance
# # ######################################################################

# data "aws_vpc" "selected" {
#   filter {
#     name   = "tag:Name"
#     values = [local.vpc_name]
#   }
# }

# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.selected.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = [for suffix in ["a-0", "b-1", "c-2"] : "${local.vpc_name}-private-us-east-1${suffix}"]
#   }
# }

# locals {
#   postgres_major_version = local.tfenv.postgres.version.major
#   postgres_minor_version = local.tfenv.postgres.version.minor
#   engine_family          = "postgres${local.postgres_major_version}"
#   postgres_version       = "${local.postgres_major_version}.${local.postgres_minor_version}"
#   service_name           = "maindb"
#   aws_region             = local.tfenv.aws.region
#   allowed_cidr_blocks    = local.tfenv.postgres.allowed_cidr_blocks
#   instance_size          = local.tfenv.postgres.instance_size
#   disk_size              = local.tfenv.postgres.disk_size
#   public_instance        = local.tfenv.postgres.public
# }

# ######################################################################
# # Additional Data required for Postgres Objects within the Instance
# ######################################################################

# data "aws_secretsmanager_secret_version" "root_user_secret" {
#   secret_id = module.secrets_manager["${local.environment}/devops_root"].secrets_manager_version.arn
# }

# data "local_file" "postgres_databases" {
#   filename = "${path.module}/config/${local.environment}/databases.csv"
# }

# data "local_file" "postgres_schemas" {
#   filename = "${path.module}/config/${local.environment}/schemas.csv"
# }

# data "local_file" "postgres_roles" {
#   filename = "${path.module}/config/${local.environment}/roles.csv"
# }

# locals {
#   postgres_databases = csvdecode(data.local_file.postgres_databases.content)
#   postgres_schemas   = csvdecode(data.local_file.postgres_schemas.content)
#   postgres_roles     = csvdecode(data.local_file.postgres_roles.content)
# }

# ######################################################################
# # Creating the actual database
# ######################################################################

# provider "postgresql" {
#   scheme    = "awspostgres"
#   host      = module.postgres_rds.rds.db_instance.address
#   port      = 5432
#   database  = "postgres"
#   username  = jsondecode(data.aws_secretsmanager_secret_version.root_user_secret.secret_string)["username"]
#   password  = jsondecode(data.aws_secretsmanager_secret_version.root_user_secret.secret_string)["password"]
#   sslmode   = "require"
#   superuser = false
# }

# module "postgres_rds" {
#   depends_on = [
#     module.secrets_manager, # roles.csv should be updated with the ARN of the created secrets manager
#   ]
#   # source                  = "git@github.com:ioet/infra-terraform-modules.git//aws-postgresql?ref=v0.0.79"
#   source = "../../modules/aws-postgresql"
#   aws_secret_manager_name = module.secrets_manager["${local.environment}/devops_root"].secrets_manager.name
#   vpc_id                  = data.aws_vpc.selected.id
#   subnet_ids              = data.aws_subnets.private.ids
#   engine_family           = local.engine_family
#   postgres_version        = local.postgres_version
#   service_name            = local.service_name
#   environment             = local.environment
#   aws_region              = local.aws_region
#   allowed_cidr_blocks     = local.allowed_cidr_blocks
#   instance_size           = local.instance_size
#   disk_size               = local.disk_size
#   publicly_accessible     = local.public_instance
#   # username                = local.tfenv.postgres.username
# }

# module "postgres_config" {
#   depends_on = [
#     module.postgres_rds
#   ]
#   source             = "../../modules/postgresql"
#   postgres_databases = { for row in local.postgres_databases : row.name => row }
#   postgres_schemas   = { for row in local.postgres_schemas : "${row.database}/${row.name}" => row }
#   postgres_roles     = { for row in local.postgres_roles : row.name => row }
# }
