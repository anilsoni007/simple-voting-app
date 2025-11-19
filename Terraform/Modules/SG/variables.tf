variable "sg_name" {
  type        = string
  description = "Name of the security group"
}

variable "sg_description" {
  type    = string
  default = "Managed by Terraform"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where SG will be created"
}

variable "ingress_rules" {
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "tags" {
  type    = map(string)
  default = {}
}

