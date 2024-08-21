data "aws_iam_policy_document" "aws-backup-service-assume-role-policy-doc" {
  statement {
    sid     = "AssumeServiceRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "aws-backup-service-policy" {
  name = "aws_backup_more_services"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*",
          "cloudfront:*",
          "cognito-identity:*",
          "s3:*",
          "cloudwatch:*",
          "events:*"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}

data "aws_caller_identity" "current_account" {}

data "aws_iam_policy_document" "pass-role-policy-doc" {
  statement {
    sid       = "PassRole"
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:role/*"]
  }
}

/* Roles for taking AWS Backups */
resource "aws_iam_role" "aws-backup-service-role" {
  name               = "WSBackupServiceRole"
  description        = "Allows the AWS Backup Service to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.aws-backup-service-assume-role-policy-doc.json
}

resource "aws_iam_role_policy" "backup-service-aws-backup-role-policy" {
  policy = aws_iam_policy.aws-backup-service-policy.policy
  role   = aws_iam_role.aws-backup-service-role.name
}

resource "aws_iam_role_policy" "backup-service-pass-role-policy" {
  policy = data.aws_iam_policy_document.pass-role-policy-doc.json
  role   = aws_iam_role.aws-backup-service-role.name
}

resource "aws_backup_plan" "aws_backup_plan" {
  name = var.backup_plan_name

  rule {
    rule_name         = var.backup_rule_name
    target_vault_name = aws_backup_vault.aws_backup_vault.name
    schedule          = var.schedule
  }
}

resource "aws_backup_selection" "aws_backup_selection" {
  iam_role_arn = aws_iam_role.aws-backup-service-role.arn
  name         = var.aws_backup_selection_name
  plan_id      = aws_backup_plan.aws_backup_plan.id
  resources    = var.backup_resource_arn
}

resource "aws_backup_vault" "aws_backup_vault" {
  name        = var.backup_vault_name
  kms_key_arn = var.kms_key_arn
}
