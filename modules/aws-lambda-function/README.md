<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_command"></a> [command](#input\_command) | overrides container command value | `list(string)` | `[]` | no |
| <a name="input_entry_point"></a> [entry\_point](#input\_entry\_point) | overrides container entry\_point value | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | env: qa, stage or prod | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables to be passed in | `map(string)` | `{}` | no |
| <a name="input_execution_role_data"></a> [execution\_role\_data](#input\_execution\_role\_data) | Lambda execution IAM role name and arn | <pre>object({<br>    name = string<br>    arn  = string<br>  })</pre> | `null` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | path to the root executable file | `string` | n/a | yes |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR image URI | `string` | `null` | no |
| <a name="input_logs_retention_in_days"></a> [logs\_retention\_in\_days](#input\_logs\_retention\_in\_days) | Number of days for which cloudwatch logs should retain build logs. Defaults to 365 | `number` | `365` | no |
| <a name="input_memory_size_mb"></a> [memory\_size\_mb](#input\_memory\_size\_mb) | fucntion memory limit. Defaults to 128, the lambda default value | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | Lambda function name | `string` | n/a | yes |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | n/a | `string` | `"Zip"` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | runtime lambda function: golang, python, node, etc | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs associated with the lambda function | `list(string)` | `[]` | no |
| <a name="input_source_archive_path"></a> [source\_archive\_path](#input\_source\_archive\_path) | Path to the source code | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs associated with the lambda function | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags | `map(string)` | `{}` | no |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | function execution timeout in seconds. Defaults to 3, the lambda default | `number` | `3` | no |
| <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory) | overrides container working\_directory value | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | function ARN |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | function name |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway |
<!-- END_TF_DOCS -->