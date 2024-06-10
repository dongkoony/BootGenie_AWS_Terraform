provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones = var.availability_zones
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  web_instance_count = var.web_instance_count
  app_instance_count = var.app_instance_count
  instance_type = var.instance_type
  ami_id = var.ami_id
}

module "elb" {
  source = "./modules/elb"
  
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  web_instance_ids = module.ec2.web_instance_ids
}

module "route53" {
  source = "./modules/route53"
  
  domain_name = var.domain_name
  elb_dns_name = module.elb.elb_dns_name
  elb_zone_id = module.elb.elb_zone_id
}