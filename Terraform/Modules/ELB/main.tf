resource "aws_lb" "ELB" {
  name                       = var.ELB_Name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.ELB_SG]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  tags = {
    Environment = "Sandbox"
  }
}

resource "aws_lb_target_group" "LB_TG" {
  name        = var.LB_Target_Group_Name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.lb_target_type
  health_check {
    enabled  = true
    interval = 30
    path     = "/health/live"
    port     = 5000
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.ELB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.LB_TG.arn
  }
}