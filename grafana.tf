# # ./grafana.tf

# data "local_file" "grafana_user_data_script" {
#   filename = "script/grafana_container.sh"
# }

# resource "aws_instance" "grafana_master" {
#   ami           = "ami-01ed8ade75d4eee2f" # ubuntu 22.04 LTS
#   instance_type = "t2.small"
#   subnet_id     = element(module.vpc.public_subnet_ids, 0)
#   key_name      = var.key_name
  
#   vpc_security_group_ids = [aws_security_group.grafana_sg.id]

#   user_data = data.local_file.grafana_user_data_script.content

#   tags = {
#     Name = "Grafana-Master-instance-#0"
#   }

#   lifecycle {
#     ignore_changes = [user_data]
#   }
# }

# resource "aws_security_group" "grafana_sg" {
#   name_prefix = "grafana-sg"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# # Grafana Port
#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 9090
#     to_port     = 9090
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 9100
#     to_port     = 9100
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 1717
#     to_port     = 1717
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# data "aws_route53_zone" "grafana" {
#   name         = var.grafana_domain_name
#   private_zone = false
# }

# resource "aws_route53_record" "grafana" {
#   zone_id = data.aws_route53_zone.grafana.zone_id
#   name    = "grafana.${var.grafana_domain_name}"
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.grafana_master.public_ip]
# }
