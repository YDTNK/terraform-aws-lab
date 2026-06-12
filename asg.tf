resource "aws_autoscaling_group" "nginx_asg" {
  name = "nginx-asg"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  vpc_zone_identifier = [
    module.vpc.private_subnet_a_id,
    module.vpc.private_subnet_c_id
  ]

  target_group_arns = [
    aws_lb_target_group.tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.nginx.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-nginx-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
