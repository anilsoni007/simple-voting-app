variable "ecs_cluster_name" {
  type = string
}

variable "task_def_name" {
  type = string
}

variable "ecs_svc_name" {
  type = string
}

variable "ECS_LB_TG_Arn" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "ECS_SG" {

}

variable "ECS_Svc_Subnets" {

}

variable "task_cpu" {
  type    = number
  default = 1024
}

variable "task_memory" {
  type    = number
  default = 2048
}

variable "image_repo" {
  type    = string
  default = "asoni007/voting-app:latest"
}

variable "rds_endpoint" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_db_name" {
  type = string
}
