
variable "postgres_databases" {
  description = "What Postgres Databases (beyond the initial databases created by RDS) should be created? Default: {} (no additional databases, the only required field is .name, .owner defaults to the db user used by terraform ['DEFAULT'] and .encoding defaults to 'UTF8')"
  type        = any #object({
  #any_key => object({ # TODO: how to allow any key, but restrict types on subobjects
  #    name = string
  #    owner = optional(string)
  #    encoding = optional(string)
  #})
  #})
  default = {}
}

variable "postgres_schemas" {
  description = "What Postgres Schemas (beyond the initial schemas created by Postgres) should be created? Default: {} (no additional schema, the only required fields are .name and .database, .owner defaults to the db user used by terraform ['DEFAULT'])"
  type        = any #object({
  #any_key => object({ # TODO: how to allow any key, but restrict types on subobjects
  #    name = string
  #    database = string
  #    owner = optional(string)
  #})
  #})
  default = {}
}

variable "postgres_roles" {
  description = "What Postgres Roles/Users (beyond the initial users/roles created by RDS) should be created? Default: {} (no additional roles/users, the only required fields are .name and .secret_arn, .create_database and .create_role default to false, .inherit defaults to true, .login defaults to true when .secret_arn is not an empty string otherwise false, .roles defaults to [])"
  type        = any #object({
  #any_key => object({ # TODO: how to allow any key, but restrict types on subobjects
  #    name = string
  #    create_database = optional(bool)
  #    create_role = optional(bool)
  #    inherit = optional(bool)
  #    login = optional(bool)
  #    roles = optional(list(string))
  #    secret_arn = string
  #})
  #})
  default = {}
}

variable "postgres_grants" {
  description = "What Postgres Grants (beyond the initial grants created by RDS) should be created? Default: {} (no additional grants, the only required field are .database, .role and .object_type, .schema defaults to null, .privileges defaults to [] [GRANT becomes a REVOKE all], .objects defaults to [] [which is a wildcard representing everything], .columns defaults to [] (no columns), .with_grant_option defaults to false [this grant can not be granted to other users/roles by the grantee])"
  type        = any #object({
  #any_key => object({ # TODO: how to allow any key, but restrict types on subobjects
  #    database = string
  #    role = string
  #    schema = optional(string)
  #    object_type = string
  #    objects = optional(list(string))
  #    columns = optional(list(string))
  #    privileges = optional(list(string))
  #    with_grant_option = optional(bool)
  #})
  #})
  default = {}
}
