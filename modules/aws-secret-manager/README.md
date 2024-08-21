<!-- BEGIN_TF_DOCS -->
# ioet/infra-terraform-modules/aws-secret-manager
This module deploys a secret manager service.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.secrets_manager_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data"></a> [data](#input\_data) | JSON Data for Secrets Manager | `map` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Secrets Manager Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager"></a> [secrets\_manager](#output\_secrets\_manager) | Secret manager object |
| <a name="output_secrets_manager_version"></a> [secrets\_manager\_version](#output\_secrets\_manager\_version) | Secret manager version |
<!-- END_TF_DOCS -->