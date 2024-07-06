# ./modules/acm/variables.tf

variable "domain_name" {
  description = "ACM 인증서를 요청할 도메인 이름"
  type        = string
  default     = "value"
}

variable "route53_zone_id" {
  description = "도메인의 Route53 호스티드 존 ID"
  type        = string
  default     = "value"
}

variable "ttl" {
  description = "ttl"
  type        = number
  default     = 1800
}