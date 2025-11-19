output "vpc_name" {
  value = module.vpc.vpc_name
}

output "public_subnet_ids" {
  value = module.subnets.pub_subnet_id
}

output "private_subnets_id" {
  value = module.subnets.priv_subnet_id
}

output "ELB-SG-ID" {
  value = module.SG.SG_ID
}