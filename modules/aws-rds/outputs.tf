output "db_instance" {
  description = "The RDS instance"
  value       = aws_db_instance.api_database_instance
}

output "db_host" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.api_database_instance.endpoint
}

output "db_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.api_database_instance.port
}

output "db_name" {
  description = "The database name of the RDS instance"
  value       = aws_db_instance.api_database_instance.db_name
}

output "db_username" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.api_database_instance.username
}
