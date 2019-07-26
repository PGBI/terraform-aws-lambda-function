output "arn" {
  description = "ARN of the lambda function."
  value       = aws_lambda_function.main.arn
}

output "name" {
  description = "Name of the lambda function."
  value       = aws_lambda_function.main.function_name
}

output "role_arn" {
  description = "ARN of the role assumed by the lambda funtion."
  value       = module.role.arn
}

output "role_id" {
  description = "Name of the role assumed by the lambda funtion."
  value       = module.role.id
}

output "role_name" {
  description = "Name of the role assumed by the lambda funtion."
  value       = module.role.name
}
