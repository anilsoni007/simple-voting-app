output "vpc_name" {
  value = var.vpc_name
}

output "vpc_cidr" {
  value = aws_vpc.terraform_vpc.cidr_block
}

output "vpc_id" {
  value = aws_vpc.terraform_vpc.id
}