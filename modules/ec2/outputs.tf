# ./modules/ec2/outputs.tf

# output "app_instance_ids" {
#   description = "IDs of the App instances"
#   value       = [for instance in aws_instance.app : instance.id]
# }

# output "web_instance_ids" {
#   description = "IDs of the Web instances"
#   value       = [for instance in aws_instance.web : instance.id]
# }

# output "app_instance_public_ips" {
#   description = "Public IPs of the App instances"
#   value       = [for instance in aws_instance.app : instance.public_ip]
# }

# output "web_instance_public_ips" {
#   description = "Public IPs of the Web instances"
#   value       = [for instance in aws_instance.web : instance.public_ip]
# }


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