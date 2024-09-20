variable "environment_server" {
  type = string
  default = "prod"
  description = "Enviroment to deploy"
}

resource "aws_iam_role" "base_project_ecs_execution_iam_role" {
  name               = terraform.workspace == "stg" ? "base-project-ecs-task-role-stg" : "base-project-ecs-task-role-prod"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "base_project_ecs_task_role_policy_attachment" {
  count = length(var.iam_policy_arn_task_ecs)
  role  = aws_iam_role.base_project_ecs_execution_iam_role.name
  policy_arn = var.iam_policy_arn_task_ecs[count.index]
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_security_group" "ALB_security_group" {
  name        = terraform.workspace == "stg" ? "ALB_security_group_stg" : "ALB_security_group_prod"
  description = "A security group for the ALB database"
  vpc_id      = aws_vpc.base_project_VPC.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all traffic throught HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all traffic throught HTTP"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_app_alb_security_group_stg" : "geacco_app_alb_security_group_prod"
  }
}


resource "aws_lb_target_group" "base_project_alb_target_group" { 
  name        = terraform.workspace == "stg" ? "geacco-alb-target-group-stg" : "geacco-alb-target-group-prod"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.base_project_VPC.id
  deregistration_delay = 60
  slow_start = 30

  lifecycle { create_before_destroy=true }

  health_check {
    path = "/health"
    healthy_threshold = 5
    interval = 10
    timeout = 2
    matcher = "200,301,302"
  }

}

resource "aws_lb" "base_project_alb" { // Copy
  name               = terraform.workspace == "stg" ? "geacco-ALB-stg" : "geacco-ALB-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_security_group.id]
  subnets            = [for subnet in aws_subnet.base_project_cloud_subnet : subnet.id]
}

resource "aws_lb_listener" "base_project_alb_listener" {
  load_balancer_arn = aws_lb.base_project_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.base_project_alb_target_group.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "base_project_alb_listener_https" { # Copy
  load_balancer_arn = aws_lb.base_project_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:805389546304:certificate/2b2dae1d-71ce-4c26-a766-590a72892ae6"

  default_action {
    target_group_arn = "${aws_lb_target_group.base_project_alb_target_group.id}"
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "base_project_ecs_cluster" { //Copy
  name = terraform.workspace == "stg" ? "base-project-ecs-cluster-stg" : "base-project-ecs-cluster-prod"
}


resource "aws_ecs_task_definition" "base_project_ecs_task_definition" { 
  family                   = terraform.workspace == "stg" ? "base-project-image-stg" : "base-project-image-prod"
  network_mode             = "bridge"
  execution_role_arn       = aws_iam_role.base_project_ecs_execution_iam_role.arn
  requires_compatibilities = ["EC2"]
  volume {
    name = "static_volume"
  }

  container_definitions = jsonencode([
    {
      essential   = true
      name        = terraform.workspace == "stg" ? "base-project-image-stg" : "base-project-image-prod"
      image       = "${var.REPOSITORY_URL}:${var.IMAGE_TAG}"
      memoryReservation = 1001
      environment = [
      {
        name  = "DATABASE_URL",
        value = "postgres://${local.db_creds.username}:${local.db_creds.password}@${aws_db_instance.geacco_db_instance.address}:${aws_db_instance.geacco_db_instance.port}/${aws_db_instance.geacco_db_instance.db_name}"
      },
      {
        name  = "SECRET_KEY",
        value = local.secret_keys.SECRET_KEY
      },
      {
        name  = "REDIS_URL",
        value = "redis://${aws_elasticache_replication_group.base_project_EC_replication_group.primary_endpoint_address}:6379/0"
      },
      {
        name  = "POSTGRES_PASSWORD",
        value = "${local.db_creds.password}"
      },
      {
        name  = "ENV",
        value = var.environment_server
      },
      {
        name  = "DJANGO_SUPERUSER_PASSWORD",
        value = "${var.DJANGO_SUPERUSER_PASSWORD}"
      },
      {
        name  = "DJANGO_SUPERUSER_USERNAME",
        value = "${var.DJANGO_SUPERUSER_USERNAME}"
      },
      {
        name  = "DJANGO_SUPERUSER_EMAIL",
        value = "${var.DJANGO_SUPERUSER_EMAIL}"
      }
      ],
      mountPoints = [
          {
              "sourceVolume": "static_volume",
              "containerPath": "/app/static",
              "readOnly": false
          }
      ],
      portMappings = [
        {
          containerPort = 8002,
          hostPort        = 0,
          protocol      = "tcp"
        }
      ],
      entryPoint = ["/app/setup_environment"],
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = terraform.workspace == "stg" ? "base_project_image_logs-stg" : "base_project_image_logs-prod",
            awslogs-create-group = "true",
            awslogs-region = "us-east-1",
            awslogs-stream-prefix = "ecs",
          }
      },
    },
    {
      essential   = true
      name        = terraform.workspace == "stg" ? "base-project-ngix-image-stg" : "base-project-ngix-image-prod"
      memoryReservation = 40
      image       = "${var.REPOSITORY_URL_NGINX}:${var.IMAGE_TAG_NGINX}"
      volumesFrom = [
      {
          sourceContainer = terraform.workspace == "stg" ? "base-project-image-stg" : "base-project-image-prod",
          readOnly = false
      }
      ]
      portMappings = [
        {

          containerPort = 8001,
          hostPort      = 0,
          protocol      = "tcp"
        }
      ]
      environment = [
        {
            name  = "TASK_HOST_PORT",
            value =  "8002",
        },
      ]
      dependsOn = [{
        "containerName": terraform.workspace == "stg" ? "base-project-image-stg" : "base-project-image-prod",
        "condition": "START"
      }]
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = terraform.workspace == "stg" ? "base_project_nginx_image_logs_stg" : "base_project_nginx_image_logs_prod",
            awslogs-create-group = "true",
            awslogs-region = "us-east-1",
            awslogs-stream-prefix = "ecs",
          }
      },
    }
  ])
}

resource "aws_ecs_service" "base_project_ecs_service" { 
  depends_on           = [aws_lb_listener.base_project_alb_listener]
  name                 = terraform.workspace == "stg" ? "base-project-ecs-service-stg" : "base-project-ecs-service-prod"

  launch_type          = "EC2"
  cluster              = aws_ecs_cluster.base_project_ecs_cluster.id
  force_new_deployment = true
  task_definition      = aws_ecs_task_definition.base_project_ecs_task_definition.arn
  desired_count = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = aws_lb_target_group.base_project_alb_target_group.arn
    container_name   = terraform.workspace == "stg" ? "base-project-ngix-image-stg" : "base-project-ngix-image-prod"
    container_port   = 8001 
  }
}

resource "aws_security_group" "ECS_security_group" { # Copy
  name        = terraform.workspace == "stg" ? "ECS_security_group_stg" : "ECS_security_group_prod"
  description = "A security group for the ECS"
  vpc_id      = aws_vpc.base_project_VPC.id
  ingress {
    description = "Allow all traffic throught HTTP"
    from_port   = "8001"
    to_port     = "8001"
    protocol    = "tcp"
    security_groups = [
      "${aws_security_group.ALB_security_group.id}",
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_app_ecs_security_group_stg" : "geacco_app_ecs_security_group_prod"
  }
}

resource "aws_lb_target_group" "base_project_alb_target_group_celery" {
  name        = terraform.workspace == "stg" ? "geacco-alb-tg-celery-stg" : "geacco-alb-tg-celery-prod"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.base_project_VPC.id
  deregistration_delay = 5

  lifecycle { create_before_destroy=true }

  health_check {
    path = "/"
    healthy_threshold = 2
    interval = 5
    timeout = 2
    matcher = "200,301,302"
  }

}

resource "aws_lb" "base_project_alb_celery" {
  name               = terraform.workspace == "stg" ? "geacco-ALB-celery-stg" : "geacco-ALB-celery-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_security_group.id]
  subnets            = [for subnet in aws_subnet.base_project_cloud_celery_subnet : subnet.id]
}

resource "aws_lb_listener" "base_project_celery_alb_listener" {
  load_balancer_arn = aws_lb.base_project_alb_celery.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.base_project_alb_target_group_celery.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "base_project_celery_alb_listener_https" { 
  load_balancer_arn = aws_lb.base_project_alb_celery.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:805389546304:certificate/2b2dae1d-71ce-4c26-a766-590a72892ae6"

  default_action {
    target_group_arn = "${aws_lb_target_group.base_project_alb_target_group_celery.id}"
    type             = "forward"
  }
}

resource "aws_iam_role" "base_project_celery_ecs_execution_iam_role" {
  name               = terraform.workspace == "stg" ? "base-project-celery-ecs-task-role-stg" : "base-project-celery-ecs-task-role-prod"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_ecs_cluster" "base_project_celery_ecs_cluster" { 
  name = terraform.workspace == "stg" ? "base-project-celery-ecs-cluster-stg" : "base-project-celery-ecs-cluster-prod"
}

resource "aws_ecs_task_definition" "project_celery_ecs_task_definition" { 
  family                   = terraform.workspace == "stg" ? "project-celery-stg" : "project-celery-prod"
  network_mode             = "bridge"
  execution_role_arn       = aws_iam_role.base_project_ecs_execution_iam_role.arn
  requires_compatibilities = ["EC2"]
  volume {
    name = "static_volume"
  }

  container_definitions = jsonencode([
    {
      essential   = true
      name        = terraform.workspace == "stg" ? "celery-worker-image-stg" : "celery-worker-image-prod"
      image       = "${var.REPOSITORY_URL_CELERY_WORKER}:${var.IMAGE_TAG_CELERY_WORKER}"
      memoryReservation = 800
      environment = [
      {
        name  = "DATABASE_URL",
        value = "postgres://${local.db_creds.username}:${local.db_creds.password}@${aws_db_instance.geacco_db_instance.address}:${aws_db_instance.geacco_db_instance.port}/${aws_db_instance.geacco_db_instance.db_name}"
      },
      {
        name  = "SECRET_KEY",
        value = local.secret_keys.SECRET_KEY
      },
      {
        name  = "REDIS_URL",
        value = "redis://${aws_elasticache_replication_group.base_project_EC_replication_group.primary_endpoint_address}:6379/0"
      },
      {
        name  = "POSTGRES_PASSWORD",
        value = "${local.db_creds.password}"
      },
      {
        name  = "ENV",
        value = var.environment_server
      },
      {
        name  = "DJANGO_SUPERUSER_PASSWORD",
        value = "${var.DJANGO_SUPERUSER_PASSWORD}"
      },
      {
        name  = "DJANGO_SUPERUSER_USERNAME",
        value = "${var.DJANGO_SUPERUSER_USERNAME}"
      },
      {
        name  = "DJANGO_SUPERUSER_EMAIL",
        value = "${var.DJANGO_SUPERUSER_EMAIL}"
      }
      ],
      mountPoints = [
          {
              "sourceVolume": "static_volume",
              "containerPath": "/app/static",
              "readOnly": false
          }
      ],
      portMappings = [
        {
          containerPort = 5555,
          hostPort      = 0,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = terraform.workspace == "stg" ? "celery_worker_img_logs-stg" : "celery_worker_img_logs-prod",
            awslogs-create-group = "true",
            awslogs-region = "us-east-1",
            awslogs-stream-prefix = "ecs",
          }
      },
    },
    {
      essential   = true
      name        = terraform.workspace == "stg" ? "celery-beat-image-stg" : "celery-beat-image-prod"
      image       = "${var.REPOSITORY_URL_CELERY_BEAT}:${var.IMAGE_TAG_CELERY_BEAT}"
      memoryReservation = 800
      environment = [
      {
        name  = "DATABASE_URL",
        value = "postgres://${local.db_creds.username}:${local.db_creds.password}@${aws_db_instance.geacco_db_instance.address}:${aws_db_instance.geacco_db_instance.port}/${aws_db_instance.geacco_db_instance.db_name}"
      },
      {
        name  = "SECRET_KEY",
        value = local.secret_keys.SECRET_KEY
      },
      {
        name  = "REDIS_URL",
        value = "redis://${aws_elasticache_replication_group.base_project_EC_replication_group.primary_endpoint_address}:6379/0"
      },
      {
        name  = "POSTGRES_PASSWORD",
        value = "${local.db_creds.password}"
      },
      {
        name  = "ENV",
        value = var.environment_server
      },
      {
        name  = "DJANGO_SUPERUSER_PASSWORD",
        value = "${var.DJANGO_SUPERUSER_PASSWORD}"
      },
      {
        name  = "DJANGO_SUPERUSER_USERNAME",
        value = "${var.DJANGO_SUPERUSER_USERNAME}"
      },
      {
        name  = "DJANGO_SUPERUSER_EMAIL",
        value = "${var.DJANGO_SUPERUSER_EMAIL}"
      }
      ],
      mountPoints = [
          {
              "sourceVolume": "static_volume",
              "containerPath": "/app/static",
              "readOnly": false
          }
      ],
      portMappings = [
        {
          containerPort = 5556,
          hostPort      = 0,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = terraform.workspace == "stg" ? "celery_beat_img_logs-stg" : "celery_beat_img_logs-prod",
            awslogs-create-group = "true",
            awslogs-region = "us-east-1",
            awslogs-stream-prefix = "ecs",
          }
      },
    },
    {
      name  = terraform.workspace == "stg" ? "nginx-health-status-stg": "nginx-health-status-prod" 
      image = "nginx:latest"
      memoryReservation = 100
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0,
          protocol      = "tcp"
        },
      ],
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = terraform.workspace == "stg" ? "nginx-health-status-stg" : "nginx-health-status-prod",
            awslogs-create-group = "true",
            awslogs-region = "us-east-1",
            awslogs-stream-prefix = "ecs",
          }
      },
    },
  ])
}

resource "aws_ecs_service" "base_project_celery_ecs_service" { 
  count                = var.settings_celery.web_app.count
  depends_on           = [aws_lb_listener.base_project_celery_alb_listener]
  name                 = terraform.workspace == "stg" ? "celery-ecs-service-stg" : "celery-ecs-service-prod"

  launch_type          = "EC2"
  cluster              = aws_ecs_cluster.base_project_celery_ecs_cluster.id
  force_new_deployment = true
  task_definition      = aws_ecs_task_definition.project_celery_ecs_task_definition.arn
  desired_count = 1 
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = aws_lb_target_group.base_project_alb_target_group_celery.arn
    container_name   = terraform.workspace == "stg" ? "nginx-health-status-stg" : "nginx-health-status-prod"
    container_port   = 80
  }
}

resource "aws_security_group" "ECS_security_group_celery" {
  name        = terraform.workspace == "stg" ? "ECS_security_group_celery_stg" : "ECS_security_group_celey_prod"
  description = "A security group for the ECS Celery"
  vpc_id      = aws_vpc.base_project_VPC.id
  ingress {
    description = "Allow all traffic throught HTTP"
    from_port   = "8005"
    to_port     = "8005"
    protocol    = "tcp"
    security_groups = [
      "${aws_security_group.ALB_security_group.id}",
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_app_ecs_sg_celery_stg" : "geacco_app_ecs_sg_prod"
  }
}