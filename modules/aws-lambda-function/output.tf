output "function_arn" {
  description = "function ARN"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "function name"
  value       = local.function_name
}

output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}
