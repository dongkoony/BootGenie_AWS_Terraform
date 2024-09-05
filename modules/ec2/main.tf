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
  desired_capacity    = var.app_instance_count
  min_size            = var.app_asg_min_siz
  max_size            = var.app_asg_max_siz

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [var.alb_target_group_arn_app]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-APP-Instance"
    propagate_at_launch = true
  }
}

# App Server Scale Out Policy
resource "aws_autoscaling_policy" "app_scale_out" {
  name                   = "${var.name_prefix}-app-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# App Server Scale In Policy
resource "aws_autoscaling_policy" "app_scale_in" {
  name                   = "${var.name_prefix}-app-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# App Server CPU High Alarm
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${var.name_prefix}-app-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.app_scale_out.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

# App Server CPU Low Alarm
resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "${var.name_prefix}-app-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.app_scale_in.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
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

  target_group_arns = [var.alb_target_group_arn_web]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-WEB-Instance"
    propagate_at_launch = true
  }
}

# Web Server Scale Out Policy
resource "aws_autoscaling_policy" "web_scale_out" {
  name                   = "${var.name_prefix}-web-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Web Server Scale In Policy
resource "aws_autoscaling_policy" "web_scale_in" {
  name                   = "${var.name_prefix}-web-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Web Server CPU High Alarm
resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name          = "${var.name_prefix}-web-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.web_scale_out.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

# Web Server CPU Low Alarm
resource "aws_cloudwatch_metric_alarm" "web_cpu_low" {
  alarm_name          = "${var.name_prefix}-web-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.web_scale_in.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
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