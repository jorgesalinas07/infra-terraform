
######################################################################
# Configuration
######################################################################


locals {
  prefix_name   = "${var.name}-${var.environment}-${data.aws_region.current.name}"
  function_name = local.prefix_name
}

data "aws_region" "current" {}


######################################################################
# Logs
######################################################################

resource "aws_cloudwatch_log_group" "logging" {
  name              = "/aws/lambda/${local.prefix_name}"
  retention_in_days = var.logs_retention_in_days

  tags = var.tags
}

######################################################################
# Function
######################################################################

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  role             = var.execution_role_data.arn
  description      = "Managed by Terraform."
  package_type     = var.package_type
  source_code_hash = var.package_type != "Image" ? filebase64sha256(var.source_archive_path) : null
  image_uri        = var.package_type != "Zip" ? var.image_uri : null
  filename         = var.package_type != "Image" ? var.source_archive_path : null
  runtime          = var.package_type != "Image" ? var.runtime : null
  handler          = var.package_type != "Image" ? var.handler : null
  timeout          = var.timeout_seconds
  memory_size      = var.memory_size_mb
  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  dynamic "image_config" {
    for_each = (length(var.entry_point) > 0 || length(var.command) > 0 || var.working_directory != null) && var.package_type == "Image" ? [true] : []
    content {
      entry_point       = var.entry_point
      command           = var.command
      working_directory = var.working_directory
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = var.tags
}
