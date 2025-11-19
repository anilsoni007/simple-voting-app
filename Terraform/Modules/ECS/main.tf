resource "aws_ecs_cluster" "ecs_Cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.task_def_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name  = "voting-app"
      image = "asoni007/voting-app"
      #   cpu       = 10
      #   memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_svc_name
  cluster         = aws_ecs_cluster.ecs_Cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  # availability_zone_rebalancing = DISABLED
  network_configuration {
    security_groups  = [var.ECS_SG]
    subnets          = concat(var.ECS_Svc_Subnets, [])
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ECS_LB_TG_Arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}