
########################################################################
# Retrieve Account ID
########################################################################

data "aws_caller_identity" "current_user" {}

########################################################################
# Retrieve Root User Secret from AWS Secrets Manager
########################################################################

data "aws_secretsmanager_secret" "root_user_secret" {
  name = var.aws_secret_manager_name
}

data "aws_secretsmanager_secret_version" "root_user_secret" {
  secret_id = data.aws_secretsmanager_secret.root_user_secret.arn
}

########################################################################
# RDS Instance
########################################################################

module "rds" {
  source                              = "../aws-rds"
  subnet_ids                          = var.subnet_ids
  family_engine                       = var.engine_family
  api_subnet_group                    = local.service_identifier
  api_parameter_group                 = local.service_identifier
  api_security_group                  = local.service_identifier
  vpc_id                              = var.vpc_id
  from_port_security_group            = 5432
  to_port_security_group              = 5432
  cidr_blocks                         = var.allowed_cidr_blocks
  database_identifier                 = local.service_identifier
  database_name                       = local.administrative_database
  instance_class                      = var.instance_size
  allocated_storage                   = var.disk_size
  engine                              = "postgres"
  engine_version                      = var.postgres_version
  username                            = sensitive(jsondecode(data.aws_secretsmanager_secret_version.root_user_secret.secret_string)["username"])
  db_password                         = sensitive(jsondecode(data.aws_secretsmanager_secret_version.root_user_secret.secret_string)["password"])
  publicly_accessible                 = var.publicly_accessible
  iam_database_authentication_enabled = false # TODO: underlying module requires a refactor to separate IAM Policy from RDS before this can be exposed
  region                              = var.aws_region
  iam_policy_name                     = local.service_identifier
  iam_user                            = local.service_identifier
  account_id                          = data.aws_caller_identity.current_user.account_id
}
