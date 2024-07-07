# ./modules/acm/variables.tf

variable "domain_name" {
  description = "ACM 인증서를 요청할 도메인 이름"
  type        = string
  default     = "value"
}

variable "ttl" {
  description = "ttl"
  type        = number
  default     = 1800
}