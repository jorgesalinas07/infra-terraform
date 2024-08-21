/**
 * # hello-world
 *
 * This is a basic example of how to use this module.
 * It creates two lambda functions with a shared
 * service role.
 */

terraform {
  required_version = "~> 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.32.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    environment = "stage"
    service     = "hello-world"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "100.0.1.0/24"

  tags = {
    environment = "stage"
    service     = "hello-world"
  }
}

resource "aws_security_group" "hello_world" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "hello-world-shared-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

module "hello_world" {
  source                 = "../"
  name                   = "hello-world"
  environment            = "stage"
  execution_role_name    = aws_iam_role.execution.name
  source_archive_path    = "./app/app.zip"
  package_type           = "Zip"
  handler                = "handler"
  runtime                = "python3.10"
  logs_retention_in_days = 7
  timeout_seconds        = 300
  environment_variables = {
    "FOO" = "foo"
    "BAR" = "bar"
  }
  subnet_ids         = aws_subnet.main.id
  security_group_ids = [aws_security_group.hello_world.id]
  tags = {
    environment = "stage"
    service     = "hello-world"
  }
}
