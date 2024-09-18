## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >=1.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | ../aws-rds | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.root_user_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.root_user_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR Blocks allowed to connect to the database | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The aws region identifier where this should be deployed | `string` | n/a | yes |
| <a name="input_aws_secret_manager_name"></a> [aws\_secret\_manager\_name](#input\_aws\_secret\_manager\_name) | Name of the AWS Secret Manager that stores root user credentials for RDS instance | `string` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk Size in GB, default: 5 GB | `number` | `5` | no |
| <a name="input_engine_family"></a> [engine\_family](#input\_engine\_family) | Engine Family to be passed to RDS | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment that this is deployed to | `string` | n/a | yes |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | Size of the RDS Instance | `string` | n/a | yes |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | PostgreSQL Version (major.minor) to be used | `string` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Should this database be publicly accessible? Default: false (database instance is private) | `bool` | `false` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Service Name with which associated resources should be named and tagged | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs where the RDS Instance is allowed to be provisioned | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the RDS Instance will be provisioned | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds"></a> [rds](#output\_rds) | RDS Instance |
