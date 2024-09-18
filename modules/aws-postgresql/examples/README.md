## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
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
| <a name="module_gitea_secrets_manager"></a> [gitea\_secrets\_manager](#module\_gitea\_secrets\_manager) | ../../aws-secret-manager | n/a |
| <a name="module_postgres_config"></a> [postgres\_config](#module\_postgres\_config) | ../../postgresql | n/a |
| <a name="module_postgres_rds"></a> [postgres\_rds](#module\_postgres\_rds) | ../ | n/a |
| <a name="module_root_secrets_manager"></a> [root\_secrets\_manager](#module\_root\_secrets\_manager) | ../../aws-secret-manager | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_version.root_user_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [external_external.gitea_sops_secrets](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.root_sops_secrets](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [local_file.postgres_databases](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.postgres_roles](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.postgres_schemas](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
