resource "aws_s3_bucket" "geacco_app_bucket" {
  bucket = terraform.workspace == "stg" ? "geacco-app-bucket-stg" : "geacco-app-bucket-prod"

  tags = {
    Name = terraform.workspace == "stg" ? "geacco_app_bucket_stg" : "geacco_app_bucket_prod"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.base_project_VPC.id
  service_name = "com.amazonaws.us-east-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "base_project_bucket_endpoint_route_table_association" {
  route_table_id  = aws_route_table.base_project_gt_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}
