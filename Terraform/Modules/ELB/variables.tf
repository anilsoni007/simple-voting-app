variable "ELB_SG" {}

variable "ELB_Name" {

}

variable "public_subnets" {
  type = list(string)
}

variable "LB_Target_Group_Name" {

}

variable "lb_target_type" {
  type = string
}

variable "vpc_id" {

}