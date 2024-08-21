
output "bucket" {
  value = aws_s3_bucket.bucket
}

output "bucket_acl" {
  value = aws_s3_bucket_acl.bucket_acl
}
