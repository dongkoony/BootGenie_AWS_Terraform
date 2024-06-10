variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "elb_dns_name" {
  description = "DNS name of the ELB"
  type        = string
}

variable "elb_zone_id" {
  description = "Zone ID of the ELB"
  type        = string
}