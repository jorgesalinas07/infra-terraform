terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "test-basic-dynamodb-table" {
  name           = "GameScores"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  attribute {
    name = "TopScore"
    type = "N"
  }

  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "test"
  }
}

data "aws_caller_identity" "current_user" {}

module "backup" {
  source                    = "../"
  backup_plan_name          = "Backup-plan-test"
  backup_rule_name          = "Backup-plan-test_rule"
  schedule                  = "cron(0 2 * * ? *)"
  aws_backup_selection_name = "Backup-plan-test-selection"
  backup_resource_arn       = [aws_dynamodb_table.test-basic-dynamodb-table.arn]
  backup_vault_name         = "Backup-plan-test-selection"
  kms_key_arn               = "arn:aws:kms:us-east-1:095925216701:key/f5d3ca42-68d0-4c7b-ac87-4185144ea12f"
  iam_arns                  = ["arn:aws:iam::095985216701:user/user-ci-cd"]
}
