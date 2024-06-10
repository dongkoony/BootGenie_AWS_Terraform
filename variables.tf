variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "web_instance_count" {
  description = "Number of web server instances"
  type        = number
}

variable "app_instance_count" {
  description = "Number of app server instances"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}