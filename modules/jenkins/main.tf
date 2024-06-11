# ./modules/ec2/main.tf

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  key_name                    = var.key_name

  user_data = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = var.tags
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
