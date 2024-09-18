
locals {
  databases = {
    for key, value in var.postgres_databases :
    key => merge(
      {
        owner    = "DEFAULT"
        encoding = "UTF8"
      },
      value
    )
  }
  schemas = {
    for key, value in var.postgres_schemas :
    key => merge(
      {
        owner = "DEFAULT"
      },
      value
    )
  }
  roles = {
    for key, value in var.postgres_roles :
    key => merge(
      {
        create_database = false
        create_role     = false
        inherit         = true
        login           = value.secret_arn != ""
        roles           = []
      },
      value
    )
  }
  grants = {
    for key, value in var.postgres_grants :
    key => merge(
      {
        schema            = null
        privileges        = []
        objects           = []
        columns           = []
        with_grant_option = false
      },
      value
    )
  }
  pre_db_grant_object_types      = [] # TODO: determine if pre_db_grants are necessary given that all types seem to require databases or schemas to already exist
  post_db_grant_object_types     = ["database"]
  post_schema_grant_object_types = ["schema", "table", "sequence", "function", "procedure", "routine", "column", "foreign_data_wrapper", "foreign_server"]
  pre_db_grants = {
    for key, value in local.grants :
    key => value
    if contains(local.pre_db_grant_object_types, value.object_type)
  }
  post_db_grants = {
    for key, value in local.grants :
    key => value
    if contains(local.post_db_grant_object_types, value.object_type)
  }
  post_schema_grants = {
    for key, value in local.grants :
    key => value
    if contains(local.post_schema_grant_object_types, value.object_type)
  }
}

module "postgresql_roles" {
  for_each = local.roles
  source   = "./postgresql_role"
  role     = each.value
}

resource "postgresql_grant" "grants_pre_database" {
  depends_on = [
    module.postgresql_roles
  ]
  for_each          = local.pre_db_grants
  database          = each.value.database
  role              = each.value.role
  schema            = each.value.object_type != "database" ? each.value.schema : null
  object_type       = each.value.object_type
  objects           = each.value.objects
  columns           = each.value.object_type == "column" ? each.value.columns : null
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option
}

resource "postgresql_database" "databases" {
  depends_on = [
    module.postgresql_roles
  ]
  for_each = local.databases
  name     = each.value.name
  owner    = each.value.owner
  encoding = each.value.encoding
}

resource "postgresql_grant" "grants_post_database" {
  depends_on = [
    postgresql_database.databases
  ]
  for_each          = local.post_db_grants
  database          = each.value.database
  role              = each.value.role
  schema            = each.value.object_type != "database" ? each.value.schema : null
  object_type       = each.value.object_type
  objects           = each.value.objects
  columns           = each.value.object_type == "column" ? each.value.columns : null
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option
}

resource "postgresql_schema" "schemas" {
  depends_on = [
    postgresql_database.databases,
    postgresql_grant.grants_post_database
  ]
  for_each = local.schemas
  name     = each.value.name
  database = each.value.database
  owner    = each.value.owner
}

resource "postgresql_grant" "grants_post_schema" {
  depends_on = [
    postgresql_schema.schemas
  ]
  for_each          = local.post_schema_grants
  database          = each.value.database
  role              = each.value.role
  schema            = each.value.object_type != "database" ? each.value.schema : null
  object_type       = each.value.object_type
  objects           = each.value.objects
  columns           = each.value.object_type == "column" ? each.value.columns : null
  privileges        = each.value.privileges
  with_grant_option = each.value.with_grant_option
}
