output "ELB_arn" {
  value = aws_lb.ELB.arn
}

output "ELB_URl" {
  value = aws_lb.ELB.dns_name
}

output "ELB_SG" {
  value = var.ELB_SG
}

output "LB_TG_Arn" {
  value = aws_lb_target_group.LB_TG.arn
}