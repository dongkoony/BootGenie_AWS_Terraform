# ./modules/wafv2/variables.tf

# WAF 자원 접두사 변수
variable "waf_prefix" {
  description = "WAF 리소스의 접두사"
  type        = string
}

# WAF IP 세트 목록 변수
variable "waf_ip_sets" {
  description = "IP 세트 목록"
  type        = list(object({
    name      = string  # IP 세트 이름
    addresses = list(string)  # IP 주소 목록
  }))
}

# 관리형 규칙 목록 변수
variable "managed_rules" {
  description = "관리형 규칙 목록"
  type        = list(object({
    name   = string  # 규칙 이름
    vendor = string  # 규칙 공급자
  }))
}

# 환경 변수
variable "environment" {
  description = "환경 (예: Production, Staging)"
  type        = string
}

# 프로젝트 변수
variable "project" {
  description = "프로젝트 이름"
  type        = string
}
