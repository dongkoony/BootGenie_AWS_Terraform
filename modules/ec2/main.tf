resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count         = var.web_instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

resource "aws_instance" "app" {
  count         = var.app_instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "app-server-${count.index + 1}"
  }
}