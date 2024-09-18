
output "secrets_manager" {
  value       = resource.aws_secretsmanager_secret.secrets_manager
  description = "Secret manager object"
}

output "secrets_manager_version" {
  value       = resource.aws_secretsmanager_secret_version.secrets_manager_version
  description = "Secret manager version"
}
