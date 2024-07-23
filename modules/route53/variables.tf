variable "domain_name" {
  description = "도메인 이름"
  type        = string
  default     = "boot-genie-test.click"
}

variable "alb_dns_name" {
  description = "ALB의 DNS 이름"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB의 호스팅 영역 ID"
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  type        = string
}