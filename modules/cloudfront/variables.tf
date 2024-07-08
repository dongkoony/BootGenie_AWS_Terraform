# ./modules/cloudfront/variables.tf

# 오리진 도메인 이름 변수
variable "origin_domain_name" {
  description = "오리진의 도메인 이름"
  type        = string
}

# 오리진 ID 변수
variable "origin_id" {
  description = "오리진 ID"
  type        = string
}

# 타겟 오리진 ID 변수
variable "target_origin_id" {
  description = "타겟 오리진 ID"
  type        = string
}

# 웹 ACL ID 변수
variable "web_acl_id" {
  description = "웹 ACL ID"
  type        = string
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
