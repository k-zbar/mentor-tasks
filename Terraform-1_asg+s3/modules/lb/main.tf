# Create Application LB
resource "aws_lb" "lb-web" {
  name               = "LB-Web-Server"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-lb.id]
  subnets            = var.pub-subnets
}

# Create target group with health checks
resource "aws_lb_target_group" "lb-tg" {
  name     = "LB-TG"
  port     = var.http-port
  protocol = var.protocol
  vpc_id   = var.vpc-1
  health_check {
    healthy_threshold   = var.healthy-threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.interval
  }
}

# Create listeners for LB
resource "aws_lb_listener" "lb-web-listener" {
  load_balancer_arn = aws_lb.lb-web.id
  port              = var.http-port
  protocol          = var.protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.id
  }
}

# Create security group for LB
resource "aws_security_group" "sg-lb" {
  name   = "SQ for LB - open HTTP port"
  vpc_id = var.vpc-1
  ingress {
    from_port   = var.http-port
    to_port     = var.http-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-FOR-LB"
  }
}