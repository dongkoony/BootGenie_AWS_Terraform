# ./jenkins.tf


data "aws_route53_zone" "jenkins" {
  name         = var.jenkins_domain_name
  private_zone = false
}

data "aws_route53_zone" "grafana" {
  name         = var.grafana_domain_name
  private_zone = false
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.jenkins.zone_id
  name    = "jenkins.${var.jenkins_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.jenkins_master.public_ip]
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.grafana.zone_id
  name    = "grafana.${var.grafana_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.jenkins_master.public_ip]
}


data "local_file" "jenkins_user_data_script" {
  filename = "script/jenkins_container.sh"
}

resource "aws_instance" "jenkins_master" {
  ami           = "ami-01ed8ade75d4eee2f" # ubuntu 22.04 LTS
  instance_type = "t2.small"
  subnet_id     = element(module.vpc.public_subnet_ids, 0)
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = data.local_file.jenkins_user_data_script.content

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

# Traefik 리버스 프록시 설정 .toml

  provisioner "file" {
    source      = "./traefik.toml"
    destination = "/home/ubuntu/traefik.toml"
  }

  provisioner "file" {
    source      = "./prometheus.yaml"
    destination = "/home/ubuntu/prometheus.yaml"
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

  dynamic "ingress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
}