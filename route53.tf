# ./route53

locals {
  domain_name = "boot-genie-test.click"
}

# 이미 존재하는 Route 53 호스팅 영역 가져오기
data "aws_route53_zone" "main" {
  name = local.domain_name
}

# NS 레코드 설정
resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "NS"
  ttl     = 172800

  records = [
    "ns-1361.awsdns-42.org.",
    "ns-1882.awsdns-43.co.uk.",
    "ns-405.awsdns-50.com.",
    "ns-669.awsdns-19.net."
  ]
  allow_overwrite = true  # 레코드 덮어쓰기 허용

  lifecycle {
    create_before_destroy = true
    ignore_changes = [records]
  }
}

# A 레코드 설정 (www 서브도메인)
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${local.domain_name}"
  type    = "A"
  ttl     = 300

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

# Route 53 모듈 호출 수정
module "route53" {
  source         = "./modules/route53"
  domain_name    = local.domain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
  route53_zone_id = data.aws_route53_zone.main.zone_id
  depends_on     = [module.alb]
}
