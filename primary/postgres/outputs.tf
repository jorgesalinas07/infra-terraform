
# output "secrets_arn" {
#   value = {
#     for app in local.secrets_apps : app => {
#       for environment in local.secrets_environments :
#       environment => module.secrets_manager["${environment}/${app}"].secrets_manager.arn
#       if contains(local.secrets_ids, "${environment}/${app}")
#     }
#   }
# }

# output "rds" {
#   description = "The RDS instance"
#   value       = module.postgres_rds.rds.db_instance
#   sensitive   = true
# }
