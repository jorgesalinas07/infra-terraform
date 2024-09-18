resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_ownership_controls,
    aws_s3_bucket_public_access_block.bucket_public_access_block,
  ]

  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "kms_key_encryption" {
  count       = var.use_default_kms_key_for_encryption ? 1 : 0
  description = "kms key encryption to s3 bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  count  = var.use_default_kms_key_for_encryption ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_key_encryption[count.index].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

module "backup" {
  source                    = "../aws-resource-backup"
  backup_plan_name          = "Backup_${var.bucket_name}_plan"
  backup_rule_name          = "Backup_${var.bucket_name}_rule"
  schedule                  = "cron(0 2 * * ? *)"
  aws_backup_selection_name = "aws_backup_selection_${var.bucket_name}"
  backup_resource_arn       = [aws_s3_bucket.s3_bucket.arn]
  backup_vault_name         = "aws_backup_vault_${var.bucket_name}"
}
