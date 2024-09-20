resource "aws_subnet" "base_project_cloud_celery_subnet" {
  count             = var.subnet_count.cloud_public
  vpc_id            = aws_vpc.base_project_VPC.id
  cidr_block        = var.cloud_subnet_cidr_block_celery[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_app_cloud_celery_stg_${count.index}" : "geacco_app_cloud_celery_prod_${count.index}"
  }
}

resource "aws_key_pair" "geacco_app_celery_kp" {
  key_name   = terraform.workspace == "stg" ? "geacco_app_celery_kp_stg" : "geacco_app_celery_kp_prod"
  public_key = local.EC2_instance_pub_key_secrets.EC2_instance_secret_key_pub
}

data "aws_ami" "ecs_ami_celery" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_instance" "base_project_celery_EC2_instance" {
  count                       = var.settings_celery.web_app.count
  ami                         = data.aws_ami.ecs_ami_celery.id
  instance_type               = var.settings_celery.web_app.instance_type 
  subnet_id                   = aws_subnet.base_project_cloud_celery_subnet[count.index].id
  key_name                    = aws_key_pair.geacco_app_celery_kp.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.celery_repository_intance_profile.name
  vpc_security_group_ids      = [aws_security_group.EC2_security_group.id]

  user_data_base64            = terraform.workspace == "stg" ? filebase64("user_data_celery_stg.sh") : filebase64("user_data_celery.sh")

  //Use this only in creation, not in update
  #root_block_device {
  #  volume_size = 40
  #}

  #ebs_block_device {
  #  device_name = "/dev/xvda"
  #  volume_size = 40
  #}

  #ebs_block_device {
  #  device_name = "/dev/xvdcz"
  #  volume_size = 110
  #}

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_EC2_celery_instance_stg" : "geacco_EC2_celery_instance_prod"
  }
}

resource "aws_eip" "geacco_EC2_celery_eip" {
  count = var.settings_celery.web_app.count

  instance = aws_instance.base_project_celery_EC2_instance[count.index].id 

  vpc = true

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_EC2_iep_celery_instance_stg" : "geacco_EC2_iep_celery_instance_prod"
  }
}



resource "aws_route_table" "base_celery_route_table" {
  vpc_id = aws_vpc.base_project_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.base_project_gw.id
  }

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_celery_route_table_stg" : "geacco_celery_route_table_prod"
  }
}

resource "aws_route_table_association" "base_celery_route_table_association" {
  count          = var.subnet_count.cloud_public
  subnet_id      = aws_subnet.base_project_cloud_celery_subnet[count.index].id
  route_table_id = aws_route_table.base_celery_route_table.id
}
