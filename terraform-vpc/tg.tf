resource "aws_lb_target_group" "nginx" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"

  vpc_id   = aws_vpc.main.id   # ← ここが超重要
}
