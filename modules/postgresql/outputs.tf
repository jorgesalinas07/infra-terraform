
output "roles" {
  value = module.postgresql_roles
}

output "grants" {
  value = {
    pre_db      = postgresql_grant.grants_pre_database
    post_db     = postgresql_grant.grants_post_database
    post_schema = postgresql_grant.grants_post_schema
  }
}

output "databases" {
  value = postgresql_database.databases
}

output "schemas" {
  value = postgresql_schema.schemas
}
