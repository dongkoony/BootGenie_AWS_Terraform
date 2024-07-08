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
data "aws_route53_zone" "selected" {
  name         = local.domain_name
  private_zone = false
  depends_on   = [aws_route53_zone.main]
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

# resource "aws_iam_role" "ssm_role" {
#   name = "${var.name_prefix}-ssm-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm_attach" {
#   role       = aws_iam_role.ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ssm_profile" {
#   name = "${var.name_prefix}-ssm-profile"
#   role = aws_iam_role.ssm_role.name
# }

# ACM 인증서 생성 및 검증
module "acm" {
  source = "./modules/acm"
  domain_name     = local.domain_name
  route53_zone_id = data.aws_route53_zone.selected.zone_id
  ttl             = var.ttl
  depends_on      = [aws_route53_zone.main]
}

# ACM 인증서 ARN을 자동으로 가져오기 위한 데이터 소스 정의
data "aws_acm_certificate" "selected" {
  domain   = local.domain_name
  statuses = ["ISSUED"]
  depends_on = [module.acm]
}

# Route 53 레코드 생성
module "route53" {
  source         = "./modules/route53"
  domain_name    = local.domain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
  depends_on     = [module.alb]
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



## <-------------------------------WAFv2 테스트 중------------------------------->
# module "waf" {
#   source = "./modules/wafv2"

#   waf_prefix      = var.waf_prefix
#   waf_ip_sets     = var.waf_ip_sets
#   managed_rules   = var.managed_rules
#   domain_name     = var.origin_domain_name
#   origin_id       = var.origin_id
#   target_origin_id = var.target_origin_id
# }

# resource "aws_cloudfront_distribution" "cf_distribution" {
#   origin {
#     domain_name = var.origin_domain_name
#     origin_id   = var.origin_id
#   }

#   enabled = true

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = var.target_origin_id

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   web_acl_id = module.waf.waf_acl_id

#   tags = {
#     Environment = "Production"
#     Project     = "BootGenie"
#   }
# }
