
terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

data "aws_secretsmanager_secret" "user_secret" {
  count = var.role.secret_arn != "" ? 1 : 0
  arn   = var.role.secret_arn
}

data "aws_secretsmanager_secret_version" "user_secret" {
  count     = var.role.secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.user_secret[0].id
}

resource "postgresql_role" "role" {
  name            = var.role.name
  create_database = var.role.create_database
  create_role     = var.role.create_role
  inherit         = var.role.inherit
  login           = var.role.login
  roles           = jsondecode(var.role.roles)
  password        = var.role.secret_arn != "" ? sensitive(jsondecode(data.aws_secretsmanager_secret_version.user_secret[0].secret_string)["password"]) : ""
}
