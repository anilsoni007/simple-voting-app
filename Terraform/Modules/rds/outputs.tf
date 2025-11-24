output "secret_manager_arn" {
  value = aws_secretsmanager_secret_version.secret_manager_String.id
}

output "secret_manager_name" {
  value = aws_secretsmanager_secret.db_creds.name
}

output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "db_username" {
  value = var.rds_username
}

output "db_password" {
  value     = random_password.password.result
  sensitive = true
}

output "db_name" {
  value = var.database_name
}
