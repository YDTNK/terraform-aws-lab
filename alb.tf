resource "aws_lb" "alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    module.vpc.public_subnet_a_id,
    module.vpc.public_subnet_c_id
  ]

  tags = {
    Name = "terraform-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "terraform-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path = "/"
  }

  tags = {
    Name = "terraform-tg"
  }
}
