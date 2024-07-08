# ./modules/acm/main.tf

# 리소스: ACM 인증서를 생성합니다.
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "ACM Certificate for ${var.domain_name}"
  }
}

# 리소스: ACM 인증서의 DNS 검증을 위한 Route 53 레코드를 생성합니다.
resource "aws_route53_record" "cert_validation" {
  # for_each를 사용하여 각 도메인 검증 옵션에 대해 레코드를 생성합니다.
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  # 가져온 호스팅 영역의 ID를 사용합니다.
  zone_id = var.route53_zone_id

  # 각 검증 옵션의 이름, 타입, 값을 설정합니다.
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]

  # TTL 값을 설정합니다.
  ttl     = var.ttl
}

# 리소스: ACM 인증서 검증을 설정합니다.
resource "aws_acm_certificate_validation" "cert_validation" {
  # 생성된 인증서의 ARN을 사용합니다.
  certificate_arn         = aws_acm_certificate.cert.arn

  # 검증 레코드의 FQDN을 사용하여 검증을 완료합니다.
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 출력: ACM 인증서의 ARN을 출력합니다.
output "acm_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
