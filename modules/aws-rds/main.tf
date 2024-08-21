################################################################################
# RDS
################################################################################

resource "aws_db_subnet_group" "api_subnet_group" {
  name       = var.api_subnet_group
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.api_subnet_group
  }
}

resource "aws_db_parameter_group" "api_parameter_group" {
  name   = var.api_parameter_group
  family = var.family_engine

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


resource "aws_security_group" "api_security_group" {
  name   = var.api_security_group
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.from_port_security_group
    to_port     = var.to_port_security_group
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  tags = {
    Name = var.api_security_group
  }
}

resource "aws_db_instance" "api_database_instance" {
  identifier                          = var.database_identifier
  db_name                             = var.database_name
  instance_class                      = var.instance_class
  allocated_storage                   = var.allocated_storage
  engine                              = var.engine
  engine_version                      = var.engine_version
  username                            = var.username
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.api_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.api_security_group.id]
  parameter_group_name                = aws_db_parameter_group.api_parameter_group.name
  publicly_accessible                 = var.publicly_accessible
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  apply_immediately                   = true
}

resource "aws_iam_policy" "iam_auth" {
  count       = var.iam_database_authentication_enabled ? 1 : 0
  name        = var.iam_policy_name
  path        = "/"
  description = "Policy to manage IAM Authentication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "rds-db:connect",
        "Resource" : sensitive("arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${aws_db_instance.api_database_instance.resource_id}/${var.iam_user}")
      },
    ]
  })
}
