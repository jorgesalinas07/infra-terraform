output "ecr_arn" {
  value = aws_ecr_repository.this.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "name" {
  value = aws_ecr_repository.this.name
}