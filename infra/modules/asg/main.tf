data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for ASG instances
resource "aws_security_group" "instance" {
  name        = "${var.namespace}-${var.env}-${var.name}-instance-sg"
  description = "Security group for ${var.name} ASG instances"
  vpc_id      = var.vpc_id

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-instance-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "instance_http" {
  security_group_id            = aws_security_group.instance.id
  description                  = "Allow HTTP from ALB only"
  referenced_security_group_id = var.alb_security_group_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-instance-http-ingress"
  })
}

resource "aws_vpc_security_group_egress_rule" "instance_all" {
  security_group_id = aws_security_group.instance.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-instance-egress"
  })
}

# IAM Role for EC2 instances (SSM access — no bastion needed)
resource "aws_iam_role" "instance" {
  name = "${var.namespace}-${var.env}-${var.name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-instance-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.namespace}-${var.env}-${var.name}-instance-profile"
  role = aws_iam_role.instance.name

  tags = merge(var.project_tags, {
    Name = "${var.namespace}-${var.env}-${var.name}-instance-profile"
  })
}

# Launch Template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.namespace}-${var.env}-${var.name}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.instance.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance.id]
  }

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.project_tags, {
      Name = "${var.namespace}-${var.env}-${var.name}-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.project_tags, {
      Name = "${var.namespace}-${var.env}-${var.name}-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name                = "${var.namespace}-${var.env}-${var.name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.namespace}-${var.env}-${var.name}-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.project_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# CPU-based scaling policy
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.namespace}-${var.env}-${var.name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}
