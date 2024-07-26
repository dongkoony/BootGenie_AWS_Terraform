# ./outputs.tf

output "app_launch_template_id" {
  value = module.ec2.app_launch_template_id
}

output "web_launch_template_id" {
  value = module.ec2.web_launch_template_id
}

output "app_asg_name" {
  value = module.ec2.app_asg_name
}

output "web_asg_name" {
  value = module.ec2.web_asg_name
}

output "alb_dns_name" {
  description = "ALB의 DNS 이름"
  value       = module.alb.alb_dns_name
}


##############################################
## Jenkins EC2 Script Outputs Start
##############################################
output "public_key_path" {
  value = var.public_key_path
}

output "project_root_path" {
  value = var.project_root_path
}

output "cert_email" {
  value = var.cert_email
}

output "jenkins_domain_name" {
  value = var.jenkins_domain_name
}

output "jenkins_master_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}
##############################################
## Jenkins EC2 Script Outputs End
##############################################