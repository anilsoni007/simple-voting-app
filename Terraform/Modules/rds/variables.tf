variable "db_pg_name" {
  type = string
}

variable "pg_engine_family" {
  type    = string
  default = "mysql8.0"

}

variable "db_sgroup_name" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_storage" {
  type = number
}

variable "rds_engine" {
  type    = string
  default = "mysql"
  validation {
    condition     = startswith(var.rds_engine, "mysql")
    error_message = "only mysql rds engine is supported for this voting app lab!!!!"
  }
}

variable "db_name" {
  type = string
}

variable "db_instance_class" {
  type = string

}

variable "rds_secret_manager_name" {
  type = string
}

variable "rds_username" {

}

variable "database_name" {
  type    = string
  default = "voting_db"
}