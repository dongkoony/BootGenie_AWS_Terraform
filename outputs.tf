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
