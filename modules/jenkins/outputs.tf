# ./modules/ec2/outputs.tf

output "instance_id" {
  value = aws_instance.this.id
}

output "jenkins_master_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}