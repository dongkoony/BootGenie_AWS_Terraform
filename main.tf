# main.tf

provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"
  domain_name = "donghyeonporfol.site"
}

# Route 53 호스팅 영역 생성
resource "aws_route53_zone" "main" {
  name = local.domain_name
}

# Route 53 호스팅 영역 ID 가져오기
# data "aws_route53_zone" "selected" {
#   name         = local.domain_name
#   private_zone = false
#   depends_on   = [aws_route53_zone.main]
# }

resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "NS"
  ttl     = 172800

  records = [
    "ns-816.awsdns-38.net.",
    "ns-432.awsdns-54.com.",
    "ns-1993.awsdns-57.co.uk.",
    "ns-1298.awsdns-34.org."
  ]
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ec2" {
  source = "./modules/ec2"

  # count  = length(var.availability_zones)

  name_prefix                 = var.name_prefix
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_id                      = module.vpc.vpc_id
  ingress_rules               = var.ingress_rules
  key_name                    = var.key_name
  user_data                   = var.user_data
  root_volume_size            = var.root_volume_size
  tags                        = var.tags

  availability_zones          = var.availability_zones
  subnet_id                   = module.vpc.public_subnet_ids

  app_instance_count          = var.app_instance_count
  web_instance_count          = var.web_instance_count
}


# ACM 모듈 호출 수정
module "acm" {
  source = "./modules/acm"
  domain_name     = local.domain_name
  route53_zone_id = aws_route53_zone.main.zone_id  # 여기를 수정
  ttl             = var.ttl
  depends_on      = [aws_route53_zone.main, aws_route53_record.ns]  # 여기에 ns 레코드 의존성 추가
}

# ACM 인증서 ARN을 자동으로 가져오기 위한 데이터 소스 정의
data "aws_acm_certificate" "selected" {
  domain   = local.domain_name
  statuses = ["ISSUED"]
  depends_on = [module.acm]
}

# Route 53 모듈 호출 수정
module "route53" {
  source         = "./modules/route53"
  domain_name    = local.domain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
  route53_zone_id = aws_route53_zone.main.zone_id
  depends_on     = [module.alb, aws_route53_zone.main, aws_route53_record.ns]
}

# ALB 생성
module "alb" {
  source          = "./modules/alb"
  name_prefix     = var.name_prefix
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnet_ids
  certificate_arn = data.aws_acm_certificate.selected.arn
  tags            = var.tags
  depends_on      = [module.acm]
}