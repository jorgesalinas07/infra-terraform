
variable "role" {
  description = "Object that describes a PostgreSQL User/Role"
  type = object({
    name            = string
    create_database = bool
    create_role     = bool
    inherit         = bool
    login           = bool
    roles           = string # json string representing list(string)
    secret_arn      = string
  })
}
