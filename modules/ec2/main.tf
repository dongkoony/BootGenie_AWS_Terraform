# ./modules/ec2/main.tf


# Launch Template for App Servers
resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-app-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file("${path.module}/../../script/app_instance_docker.sh"))

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [aws_security_group.instance_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.root_volume_size
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-APP-Instance"
    })
  }
}

# Auto Scaling Group for App Servers
resource "aws_autoscaling_group" "app" {
  name                = "${var.name_prefix}-app-asg"
  vpc_zone_identifier = var.subnet_id
  desired_capacity    = var.app_instance_count # 시작 시 원하는 인스턴스 수
  min_size            = var.app_asg_min_siz # 최소 인스턴스 수
  max_size            = var.app_asg_max_siz # 최대 인스턴스 수

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-APP-Instance"
    propagate_at_launch = true
  }
}

# Launch Template for Web Servers
resource "aws_launch_template" "web" {
  name_prefix   = "${var.name_prefix}-web-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file("${path.module}/../..//script/change_ssh_port.sh"))

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [aws_security_group.instance_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.root_volume_size
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-WEB-Instance"
    })
  }
}

# Auto Scaling Group for Web Servers
resource "aws_autoscaling_group" "web" {
  name                = "${var.name_prefix}-web-asg"
  vpc_zone_identifier = var.subnet_id
  desired_capacity    = var.web_instance_count
  min_size            = var.web_asg_min_siz
  max_size            = var.web_asg_max_siz

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-WEB-Instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "${var.name_prefix}-"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "random_string" "suffix" {
  length  = var.web_asg_max_siz
  special = false
  upper   = false
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.name_prefix}-ssm-role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
