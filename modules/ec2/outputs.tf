# ./modules/ec2/outputs.tf

output "app_instance_ids" {
  value = aws_instance.app[*].id
}

output "web_instance_ids" {
  value = aws_instance.web[*].id
}

output "app_instance_public_ips" {
  value = aws_instance.app[*].public_ip
}

output "web_instance_public_ips" {
  value = aws_instance.web[*].public_ip
}
