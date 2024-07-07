# variables.tf

variable "region" {
  description = "AWS 리전"
  type        = string
}

variable "vpc_name" {
  description = "VPC 이름"
  type        = string
  default     = "BootGenie-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "availability_zones" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록 목록"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"] # 기본값 설정
}

variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
  default     = "BootGenie"
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
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "인스턴스에 퍼블릭 IP 주소 할당 여부"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "보안 그룹을 생성할 VPC ID"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "보안 그룹의 인바운드 규칙 목록"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      from_port   = 1717
      to_port     = 1717
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
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

variable "domain_name" {
  description = "도메인 이름"
  type        = string
}

variable "iam_instance_profile" {
  description = "인스턴스 프로파일 IAM 역할 이름"
  type        = string
  default     = ""
}

variable "public_key_path" {
  description = "퍼블릭 키 파일 경로"
  type        = string
}

## WAFv2 관련 변수

variable "waf_prefix" {
  description = "WAF prefix 이름 설정"
  type        = string
  default     = "Boot-Genie-cloudfront"
}

variable "waf_ip_sets" {
  description = "허용된 IP 주소 목록"
  type        = list(string)
  default     = ["0.0.0.0/1", "128.0.0.0/1"] # 모든 IP 주소 허용
}

variable "ip_sets_rule" {
  description = "특정 IP 주소 또는 주소 범위에서 오는 웹 요청을 탐지하기 위한 규칙."
  type = list(object({
    name           = string
    priority       = number
    ip_set_arn     = string
    action         = string
  }))
  default = []
}

variable "managed_rules" {
  description = "AWS 관리형 WAF 규칙 목록."
  type        = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  default = [
    {
      name            = "AWSManagedRulesAdminProtectionRuleSet"
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet"
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    }
  ]
}

# variable "origin_domain_name" {
#   description = "CloudFront 오리진 도메인 이름"
#   type        = string
# }

variable "origin_id" {
  description = "origin_id"
  type        = string
  default     = "value"
}

variable "target_origin_id" {
  description = "target_origin_id"
  type        = string
  default     = "value"
}

variable "certificate_arn" {
  description = "SSL 인증서의 ARN"
  type        = string
}

# variable "route53_zone_id" {
#   description = "도메인의 Route53 호스티드 존 ID"
#   type        = string
# }

variable "ttl" {
  description = "ttl"
  type        = number
  default     = 1800
}