# ./jenkins.tf

resource "aws_iam_role" "jenkins_ssm_role" {
  name = "jenkins-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm_role_attachment" {
  role       = aws_iam_role.jenkins_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_ssm_instance_profile" {
  name = "jenkins-ssm-instance-profile"
  role = aws_iam_role.jenkins_ssm_role.name
}

data "local_file" "user_data_script" {
  filename = "script/jenkins_container.sh"
}

resource "aws_instance" "jenkins_master" {
  ami           = "ami-01ed8ade75d4eee2f" # ubuntu 22.04 LTS
  instance_type = "t2.small"
  subnet_id     = element(module.vpc.public_subnet_ids, 0)
  key_name      = var.key_name
  iam_instance_profile = aws_iam_instance_profile.jenkins_ssm_instance_profile.name
  
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = data.local_file.user_data_script.content

  tags = {
    Name = "Jenkins-Master-instance-#0"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.public_key_path)
    host        = self.public_ip
    port        = 1717
  }

# Dokcer-Compose.yaml 파일을 복사하여 EC2 인스턴스에 업로드
  provisioner "file" {
    source      = "./docker-compose.yaml"
    destination = "/home/ubuntu/docker-compose.yaml"
  }

# Dokcer-Compose.yaml 환경변수 파일을 복사하여 EC2 인스턴스에 업로드
  provisioner "file" {
    source      = "./.env"
    destination = "/home/ubuntu/.env"
  }

# get_jenkins_password.sh 파일을 복사하여 EC2 인스턴스에 업로드
  provisioner "file" {
    source      = "script/get_jenkins_password.sh"
    destination = "/home/ubuntu/get_jenkins_password.sh"
  }

  provisioner "local-exec" {
    command = "zip -r traefik.zip ./traefik"
  }

  provisioner "file" {
    source      = "traefik.zip"
    destination = "/home/ubuntu/traefik.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y unzip",  # unzip 설치 추가
      "unzip /home/ubuntu/traefik.zip -d /home/ubuntu/",
      "rm /home/ubuntu/traefik.zip"
    ]
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/get_jenkins_password.sh",
      "while [ ! -f /home/ubuntu/docker_installed ]; do sleep 10; done",  # Docker 설치 완료 대기
      "sleep 120",  # Jenkins 초기화 대기 시간
      "/home/ubuntu/get_jenkins_password.sh"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -P 1717 -i ${var.public_key_path} ubuntu@${self.public_ip}:/home/ubuntu/jenkins_initial_password.txt ./jenkins_initial_password.txt"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Jenkins Port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Traefik Port
  ingress {
    from_port   = 11118
    to_port     = 11118
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 1717
    to_port     = 1717
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

data "aws_route53_zone" "jenkins" {
  name         = var.jenkins_domain_name
  private_zone = false
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.jenkins.zone_id
  name    = "jenkins.${var.jenkins_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.jenkins_master.public_ip]
}
