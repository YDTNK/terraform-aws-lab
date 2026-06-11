resource "aws_instance" "nginx" {
  ami                    = "ami-0c3fd0f5d33134a76"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  key_name = "my-key" # ← これを追加

  user_data = file("user_data.sh")

  tags = {
    Name = "nginx-new-vpc"
  }
}
