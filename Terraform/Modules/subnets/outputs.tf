output "pub_subnet_id" {
  value = aws_subnet.pub_sub[*].id
}

output "priv_subnet_id" {
  value = aws_subnet.private_sub[*].id
}