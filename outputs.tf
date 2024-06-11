output "vpc_id" {
    value = module.vpc.vpc_id
}

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
    value = module.vpc.private_subnet_ids
}

output "app_instance_ids" {
    value = module.ec2.app_instance_ids
}

output "web_instance_ids" {
    value = module.ec2.web_instance_ids
}

output "app_instance_public_ips" {
    value = module.ec2.app_instance_public_ips
}

output "web_instance_public_ips" {
    value = module.ec2.web_instance_public_ips
}
