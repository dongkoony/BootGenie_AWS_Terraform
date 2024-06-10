output "web_instance_ids" {
  value = aws_instance.web[*].id
}

output "app_instance_ids" {
  value = aws_instance.app[*].id
}