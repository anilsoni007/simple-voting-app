output "ELB_arn" {
  value = aws_lb.ELB.arn
}

output "ELB_URl" {
  value = aws_lb.ELB.dns_name
}

output "ELB_SG" {
  value = var.ELB_SG
}