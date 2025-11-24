module "vpc" {
  source         = "./Modules/vpc"
  vpc_cidr_block = "192.168.0.0/16"
  vpc_name       = "voting-app-vpc"
}

module "subnets" {
  source           = "./Modules/subnets"
  vpc_id           = module.vpc.vpc_id
  pub_sub_cidr     = ["192.168.1.0/24", "192.168.2.0/24"]
  azs              = ["ap-south-1a", "ap-south-1b"]
  private_sub_cidr = ["192.168.3.0/24", "192.168.4.0/24"]
}

module "SG" {
  source         = "./Modules/SG"
  sg_name        = "ELB-SG"
  sg_description = "Security group for ELB"
  vpc_id         = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Name = "ELB-SG"
  }
}

module "ELB" {
  source               = "./Modules/ELB"
  ELB_SG               = module.SG.SG_ID
  ELB_Name             = "voting-app-elb"
  public_subnets       = module.subnets.pub_subnet_id
  LB_Target_Group_Name = "voting-app-target-group"
  lb_target_type       = "ip"
  vpc_id               = module.vpc.vpc_id

}

module "ECS_SG" {
  source         = "./Modules/SG"
  sg_name        = "ECS-SG"
  sg_description = "Security group for ECS"
  vpc_id         = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port       = 5000
      to_port         = 5000
      protocol        = "tcp"
      security_groups = [module.SG.SG_ID]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Name = "ECS-SG"
  }
}

module "RDS" {
  source                  = "./Modules/rds"
  db_pg_name              = "voting-app-rds-parameter-group"
  db_sgroup_name          = "voting-app-rds-subnet-group"
  db_subnet_ids           = module.subnets.priv_subnet_id
  db_name                 = "rds-voting-app"
  db_storage              = 5
  rds_engine              = "mysql"
  database_name           = "voting_db"
  db_instance_class       = "db.t3.micro"
  rds_secret_manager_name = "voting-app-creds"
  rds_username            = "admin"
}

module "ECS" {
  source           = "./Modules/ECS"
  ecs_cluster_name = "voting-app-cluster"
  task_def_name    = "voting-app-task-def"
  ecs_svc_name     = "voting-app-svc"
  image_repo       = "asoni007/voting-app:latest"
  ECS_LB_TG_Arn    = module.ELB.LB_TG_Arn
  container_name   = "voting-app"
  container_port   = 5000
  ECS_SG           = module.ECS_SG.SG_ID
  ECS_Svc_Subnets  = module.subnets.priv_subnet_id
  rds_endpoint     = module.RDS.db_endpoint
  rds_username     = module.RDS.db_username
  rds_password     = module.RDS.db_password
  rds_db_name      = module.RDS.db_name
}
