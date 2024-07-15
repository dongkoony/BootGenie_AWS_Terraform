# ./modules/ec2/variables.tf

variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "ami" {
  description = "Amazon Machine Image (AMI) ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
}

variable "subnet_id" {
  description = "인스턴스를 생성할 서브넷 ID"
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "인스턴스에 퍼블릭 IP 주소 할당 여부"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "보안 그룹을 생성할 VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "보안 그룹의 인바운드 규칙 목록"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "key_name" {
  description = "키페어 이름"
  type        = string
}

variable "root_volume_size" {
  description = "루트 볼륨 크기 (GB) 디폴트 30GB"
  type        = number
  default     = 30
}

variable "user_data" {
  description = "인스턴스 사용자 데이터 스크립트"
  type        = string
  default     = null
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default     = {}
}

# variable "availability_zone" {
#   description = "AZ"
#   type        = string
# }

variable "app_instance_count" {
  description = "생성할 앱 서버 EC2 인스턴스 수"
  type        = number
  default     = 2
}

variable "web_instance_count" {
  description = "생성할 웹 서버 EC2 인스턴스 수"
  type        = number
  default     = 2
}

variable "iam_instance_profile" {
  description = "인스턴스 프로파일 IAM 역할 이름"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "가용 영역 목록"
  type        = list(string)
}

variable "app_asg_max_siz" {
  description = "asg_max_siz"
  type        = number
  default     = 2
}

variable "web_asg_max_siz" {
  description = "asg_max_siz"
  type        = number
  default     = 2
}

variable "app_asg_min_siz" {
  description = "asg_min_siz"
  type        = number
  default     = 1
}

variable "web_asg_min_siz" {
  description = "asg_min_siz"
  type        = number
  default     = 1
}