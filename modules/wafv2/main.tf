# ./modules/wafv2/main.tf

# IP 세트 리소스 정의
resource "aws_wafv2_ip_set" "this" {
  # IP 세트 이름을 키로 하여 각 IP 세트를 생성합니다.
  for_each = { for ip_set in var.waf_ip_sets : ip_set.name => ip_set }

  name               = each.value.name
  description        = "IP set for WAF"
  scope              = "CLOUDFRONT"  # IP 세트의 적용 범위를 CLOUDFRONT로 설정
  ip_address_version = "IPV4"        # IP 주소 버전을 IPv4로 설정

  addresses = each.value.addresses  # IP 주소 목록을 설정

  tags = {
    Name = each.value.name  # 태그에 IP 세트 이름을 설정
  }
}

# WAF 웹 ACL 리소스 정의
resource "aws_wafv2_web_acl" "this" {
  name        = "${var.waf_prefix}-web-acl"  # 웹 ACL 이름을 설정
  description = "WAF ACL for CloudFront"
  scope       = "CLOUDFRONT"  # 웹 ACL의 적용 범위를 CLOUDFRONT로 설정

  default_action {
    allow {}  # 기본 액션을 허용으로 설정
  }

  # 관리형 규칙을 동적으로 생성
  dynamic "rule" {
    for_each = var.managed_rules  # managed_rules 변수에 정의된 각 규칙을 생성

    content {
      name     = rule.value.name
      priority = index(var.managed_rules, rule.value)  # 규칙 우선순위를 설정

      override_action {
        none {}  # 규칙 액션을 재정의하지 않음
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor  # 규칙 공급자를 설정
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_prefix}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment  # 태그에 환경 정보를 설정
    Project     = var.project  # 태그에 프로젝트 정보를 설정
  }
}
