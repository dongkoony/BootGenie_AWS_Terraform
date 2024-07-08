# ./modules/route53/main.tf

resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "NS"

  records = [
    "ns-799.awsdns-35.net.",
    "ns-1324.awsdns-37.org.",
    "ns-1670.awsdns-16.co.uk.",
    "ns-102.awsdns-12.com."
  ]

  ttl = 172800

  allow_overwrite = true # 기존 네임서버 덮어쓰기
}

resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
