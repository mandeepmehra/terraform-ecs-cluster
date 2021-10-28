resource "aws_lb" "applb" {
  name            = "app-alb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}


resource "aws_security_group" "lb" {
  name   = "app-alb-security-group"
  vpc_id = aws_vpc.ecsvpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.applb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "hello_world" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecsvpc.id
  target_type = "ip"
}

output "lbdnsname" {
  value = aws_lb.applb.dns_name
}