variable "name_prefix" {
  description = "리소스 이름의 접두사"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "ALB에 대한 서브넷 목록"
  type        = list(string)
}

variable "certificate_arn" {
  description = "SSL 인증서의 ARN"
  type        = string
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
}

variable "jenkins_domain" {
  description = "Domain for Jenkins"
  type        = string
  default     = "jenkins.boot-genie-test.click"
}
