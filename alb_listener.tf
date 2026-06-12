resource "aws_lb_listener" "http" {
  load_balancer_arn = module.app.lb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = module.app.target_group_arn
  }
}
