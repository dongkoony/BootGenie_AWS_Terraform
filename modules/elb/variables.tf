variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "web_instance_ids" {
  description = "IDs of the web server instances"
  type        = list(string)
}