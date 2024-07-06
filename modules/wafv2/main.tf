# 허용된 IP 세트 정의
resource "aws_wafv2_ip_set" "ipset_global" {
  name               = "${var.waf_prefix}-allowed-ips"
  scope              = "CLOUDFRONT" # 또는 "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.waf_ip_sets
}

# WAFv2 웹 ACL 설정
resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "${var.waf_prefix}-generic-acl"
  scope       = "CLOUDFRONT" # 또는 "REGIONAL"
  description = "Web ACL for ${var.waf_prefix}"
  
  default_action {
    allow {} # 기본 액션을 허용으로 설정
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "global-rule"
  }

  # 관리형 규칙 설정
  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = rule.value.name
      }
    }
  }

  # IP 세트 규칙 설정
  rule {
    name     = "allowed_ips"
    priority = 1
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipset_global.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "allowed_ips"
    }
  }
}

# CloudWatch 로그 그룹 설정
resource "aws_cloudwatch_log_group" "waf-logging" {
  name = "aws-waf-logs-${var.waf_prefix}"
}

# WAFv2 웹 ACL 로그 설정
resource "aws_wafv2_web_acl_logging_configuration" "logging_configuration" {
  log_destination_configs = [aws_cloudwatch_log_group.waf-logging.arn]
  resource_arn            = aws_wafv2_web_acl.waf_acl.arn
}

# CloudFront 배포 설정
resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = "your-origin-domain.com" # 실제 오리진 도메인으로 변경
    origin_id   = "your-origin-id"
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "your-origin-id"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.waf_acl.arn

  tags = {
    Environment = "Production"
    Project     = "BootGenie"
  }
}
