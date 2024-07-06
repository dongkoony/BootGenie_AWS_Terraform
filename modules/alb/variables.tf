variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "vpc_id" {
  description = "보안 그룹을 생성할 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  type        = list(string)
}

variable "web_instance_ids" {
  description = "웹 서버 인스턴스 ID 목록"
  type        = list(string)
}

variable "app_instance_ids" {
  description = "앱 서버 인스턴스 ID 목록"
  type        = list(string)
}
