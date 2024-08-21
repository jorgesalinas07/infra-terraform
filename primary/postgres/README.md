<!-- BEGIN_TF_DOCS -->

# PostgreSQL Management for `ioet-primary`

## Common Tasks

### Creating a new user (or role)

1. Create a new SOPS file in `secrets/<workspace>/` -- this new SOPS file should contain a username and password key.
2. Reference the new SOPS file in `secrets/<workspace>/index.csv` as a new record. See CSV schemas below for more details on the available fields.
3. `terraform workspace select <workspace> && terraform apply` to create the new secret (there should be no other changes in the plan, otherwise please request help)
4. Add a new record to `config/<workspace>/roles.csv` for your new user, using the ARN from the `terraform output`s for your newly created secret. See CSV schemas below for more details on the available fields.
5. `terraform workspace select <workspace> && terraform apply` to create the new user (there should be no other changes in the plan, otherwise please request help)

**If you need a new database role instead of a new database user, you can leave the secret arn field blank and create the new role without the ability to login for permissions inherritence. As such, steps 1, 2 and 3 can be skipped for creating new database roles.**

### Creating a new database

1. Add a new record to `config/<workspace>/databases.csv` for your new database.
2. `terraform workspace select <workspace> && terraform apply` to create the new database (there should be no other changes in the plan, otherwise please request help)

### Creating a new database schema

1. Add a new record to `config/<workspace>/schemas.csv` for your new database schema.
2. `terraform workspace select <workspace> && terraform apply` to create the new database schema (there should be no other changes in the plan, otherwise please request help)

## How this works

Each workspace contains:
- a single RDS/PostgreSQL instance
- one or more Secrets Manager
    - these are created from `secrets/<workspace>/index.csv` and the SOPS files in `secrets/<workspace>/`
- within that RDS instance the following resources are created:
    - `admindb` / a root user managed by RDS itself -- these are only to be used for database management
    - one or more database users/roles managed via `config/<workspace>/roles.csv`
    - one or more databases managed via `config/<workspace>/databases.csv`
    - one or more database schemas managed via `config/<workspace>/schemas.csv`

## Terraform Workspaces

| Workspace | Contained Environments | Description                                        |
|-----------|------------------------|----------------------------------------------------|
| `nonprod` | `qa`, `stage`          | Contains databases for non-production environments |
| `prod`    | `prod`                 | Contains databases for production environments     |

## Terraform Documentation

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.31.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >=1.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.31.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.2 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgres_config"></a> [postgres\_config](#module\_postgres\_config) | git@github.com:ioet/infra-terraform-modules.git//postgresql | v0.0.56 |
| <a name="module_postgres_rds"></a> [postgres\_rds](#module\_postgres\_rds) | git@github.com:ioet/infra-terraform-modules.git//aws-postgresql | v0.0.79 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | git@github.com:ioet/infra-terraform-modules.git//aws-secret-manager | v0.0.56 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_version.root_user_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [external_external.sops_secrets](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [local_file.postgres_databases](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.postgres_roles](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.postgres_schemas](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds"></a> [rds](#output\_rds) | The RDS instance |
| <a name="output_secrets_arn"></a> [secrets\_arn](#output\_secrets\_arn) | n/a |


<!-- END_TF_DOCS -->