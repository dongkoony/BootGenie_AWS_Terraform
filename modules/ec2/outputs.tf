# ./modules/ec2/outputs.tf

output "app_launch_template_id" {
  value = aws_launch_template.app.id
}

output "web_launch_template_id" {
  value = aws_launch_template.web.id
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}

output "web_asg_name" {
  value = aws_autoscaling_group.web.name
}