# ./modules/ec2/main.tf

resource "aws_instance" "app" {
  count                    = var.app_instance_count
  ami                      = var.ami
  instance_type            = var.instance_type
  subnet_id                = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids   = [aws_security_group.instance_sg.id]
  key_name                 = var.key_name
  user_data                = file("${path.module}/../../script/app_instance_docker.sh")
  iam_instance_profile     = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-app-instance-${count.index}" })
}

resource "aws_instance" "web" {
  count                    = var.web_instance_count
  ami                      = var.ami
  instance_type            = var.instance_type
  subnet_id                = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids   = [aws_security_group.instance_sg.id]
  key_name                 = var.key_name
  user_data                = var.user_data
  iam_instance_profile     = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-web-instance-${count.index}" })
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


# SSM IAM 사용자 추가
resource "random_string" "suffix" {
  length  = 6
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