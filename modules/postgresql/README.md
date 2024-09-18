## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.31.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >=1.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | >=1.21 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgresql_roles"></a> [postgresql\_roles](#module\_postgresql\_roles) | ./postgresql_role | n/a |

## Resources

| Name | Type |
|------|------|
| [postgresql_database.databases](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_grant.grants_post_database](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.grants_post_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.grants_pre_database](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_schema.schemas](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_postgres_databases"></a> [postgres\_databases](#input\_postgres\_databases) | What Postgres Databases (beyond the initial databases created by RDS) should be created? Default: {} (no additional databases, the only required field is .name, .owner defaults to the db user used by terraform ['DEFAULT'] and .encoding defaults to 'UTF8') | `any` | `{}` | no |
| <a name="input_postgres_grants"></a> [postgres\_grants](#input\_postgres\_grants) | What Postgres Grants (beyond the initial grants created by RDS) should be created? Default: {} (no additional grants, the only required field are .database, .role and .object\_type, .schema defaults to null, .privileges defaults to [] [GRANT becomes a REVOKE all], .objects defaults to [] [which is a wildcard representing everything], .columns defaults to [] (no columns), .with\_grant\_option defaults to false [this grant can not be granted to other users/roles by the grantee]) | `any` | `{}` | no |
| <a name="input_postgres_roles"></a> [postgres\_roles](#input\_postgres\_roles) | What Postgres Roles/Users (beyond the initial users/roles created by RDS) should be created? Default: {} (no additional roles/users, the only required fields are .name and .secret\_arn, .create\_database and .create\_role default to false, .inherit defaults to true, .login defaults to true when .secret\_arn is not an empty string otherwise false, .roles defaults to []) | `any` | `{}` | no |
| <a name="input_postgres_schemas"></a> [postgres\_schemas](#input\_postgres\_schemas) | What Postgres Schemas (beyond the initial schemas created by Postgres) should be created? Default: {} (no additional schema, the only required fields are .name and .database, .owner defaults to the db user used by terraform ['DEFAULT']) | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databases"></a> [databases](#output\_databases) | n/a |
| <a name="output_grants"></a> [grants](#output\_grants) | n/a |
| <a name="output_roles"></a> [roles](#output\_roles) | n/a |
| <a name="output_schemas"></a> [schemas](#output\_schemas) | n/a |
