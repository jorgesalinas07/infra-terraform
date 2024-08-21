resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Hold only specified amount of images",
                "selection": {
                    "tagStatus": "any",
                    "countType": "imageCountMoreThan",
                    "countNumber": ${var.count_number}
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
  EOF
}