# main.tf

provider "aws" {
  region = var.region
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

resource "aws_iam_role" "ssm_role" {
  name = "${var.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

module "alb" {
  source = "./modules/alb"

  name_prefix       = var.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  web_instance_ids  = module.ec2.web_instance_ids
  app_instance_ids  = module.ec2.app_instance_ids
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

# module "elb" {
#   source = "./modules/elb"
  
#   vpc_id = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnet_ids
#   web_instance_ids = module.ec2.web_instance_ids
# }

# module "route53" {
#   source = "./modules/route53"
  
#   domain_name = var.domain_name
#   elb_dns_name = module.elb.elb_dns_name
#   elb_zone_id = module.elb.elb_zone_id
# }