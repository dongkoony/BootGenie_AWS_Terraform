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

variable "certificate_arn" {
  description = "SSL 인증서의 ARN"
  type        = string
}

variable "ttl" {
  description = "ttl"
  type        = number
  default     = 1800
}

# NS 레코드 값 설정
variable "ns_records" {
  description = "List of NS records"
  type        = list(string)
}

##############################################
## Jenkins EC2 Script Variables Start
##############################################
variable "jenkins_domain_name" {
  description = "The domain name for the service"
  type        = string
}
##############################################
## Jenkins EC2 Script Variables End
##############################################

##############################################
## Grafana EC2 Script Variables Start
##############################################
variable "grafana_domain_name" {
  description = "The domain name for the service"
  type        = string
}
##############################################
## Grafana EC2 Script Variables End
##############################################


variable "security_group_rules" {
  description = "Security group rules"
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    },
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      type        = "ingress"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Jenkins"
    },
    {
      type        = "ingress"
      from_port   = 11118
      to_port     = 11118
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Traefik"
    },
    {
      type        = "ingress"
      from_port   = 1717
      to_port     = 1717
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Custom SSH"
    },
    {
      type        = "ingress"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Grafana"
    },
    {
      type        = "ingress"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Prometheus"
    },
    {
      type        = "ingress"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Node Exporter"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}