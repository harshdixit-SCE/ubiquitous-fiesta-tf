resource "aws_lb" "this" {
  name               = "${var.namespace}-${var.env}-${var.name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-alb"
  })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.namespace}-${var.env}-${var.name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.namespace}-${var.env}-${var.name}-alb-sg"
  description = "Security group for ${var.name} ALB"
  vpc_id      = var.vpc_id

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from allowed source"

  cidr_ipv4   = var.ingress_cidr
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-alb-http-ingress"
  })
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-alb-egress"
  })
}
