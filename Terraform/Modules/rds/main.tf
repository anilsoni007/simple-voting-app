resource "aws_db_parameter_group" "parameter" {
  name   = var.db_pg_name
  family = var.pg_engine_family
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_sgroup_name
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = var.db_sgroup_name
  }
}

data "aws_rds_engine_version" "rds_Engine" {
  engine             = "mysql"
  latest             = true
  preferred_versions = ["8.0.40", "8.0.41", "8.0.42", "8.0.43"]
}

resource "random_password" "password" {
  length           = 10
  special          = false
  override_special = "ijklmnopqabcdefrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678"
}

resource "aws_secretsmanager_secret" "db_creds" {
  name = var.rds_secret_manager_name
}

resource "aws_secretsmanager_secret_version" "secret_manager_String" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = var.rds_username,
    password = random_password.password.result
  })
}

resource "aws_db_instance" "db" {
  allocated_storage          = var.db_storage
  auto_minor_version_upgrade = false
  backup_retention_period    = 0 # sandbox rds config
  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group.name
  engine                     = var.rds_engine
  engine_version             = data.aws_rds_engine_version.rds_Engine.version
  db_name                    = var.database_name
  identifier                 = var.db_name
  instance_class             = var.db_instance_class
  multi_az                   = false # Can be customized
  password                   = random_password.password.result
  storage_encrypted          = false # sandbox rds config
  username                   = var.rds_username
}