# ./modules/acm/variables.tf

variable "domain_name" {
  description = "ACM 인증서를 요청할 도메인 이름"
  type        = string
  default     = "donghyeonporfol.site"
}

variable "ttl" {
  description = "ttl"
  type        = number
  default     = 1800
}

variable "route53_zone_id" {
  description = "Route 53 호스팅 영역 ID"
  type        = string
}