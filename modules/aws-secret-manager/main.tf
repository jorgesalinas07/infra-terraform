resource "aws_secretsmanager_secret" "secrets_manager" {
  name = var.name
}

resource "aws_secretsmanager_secret_version" "secrets_manager_version" {
  secret_id     = aws_secretsmanager_secret.secrets_manager.id
  secret_string = sensitive(jsonencode(var.data))
}
