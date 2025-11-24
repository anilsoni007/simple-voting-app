resource "aws_ecs_cluster" "ecs_Cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.ecs_cluster_name}"
  retention_in_days = 7
}

# ECS Task Execution Role - Used by ECS agent to pull images and write logs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.ecs_cluster_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.task_def_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "voting-app"
      image     = var.image_repo
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "RDS_ENDPOINT"
          value = var.rds_endpoint
        },
        {
          name  = "RDS_USERNAME"
          value = var.rds_username
        },
        {
          name  = "RDS_PASSWORD"
          value = var.rds_password
        },
        {
          name  = "RDS_DB_NAME"
          value = var.rds_db_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_svc_name
  cluster         = aws_ecs_cluster.ecs_Cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

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
