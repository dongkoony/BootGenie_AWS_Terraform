# ./modules/cloudfront/main.tf

# CloudFront 배포 리소스 정의
resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.origin_domain_name  # 오리진 도메인 이름을 설정
    origin_id   = var.origin_id  # 오리진 ID를 설정
  }

  enabled = true  # CloudFront 배포를 활성화

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]  # 허용되는 HTTP 메서드 설정
    cached_methods   = ["GET", "HEAD"]  # 캐시되는 HTTP 메서드 설정
    target_origin_id = var.target_origin_id  # 타겟 오리진 ID를 설정

    forwarded_values {
      query_string = false  # 쿼리 스트링 전달 비활성화
      cookies {
        forward = "none"  # 쿠키 전달 비활성화
      }
    }

    viewer_protocol_policy = "allow-all"  # 모든 프로토콜 허용
    min_ttl                = 0  # 최소 TTL 설정
    default_ttl            = 86400  # 기본 TTL 설정
    max_ttl                = 31536000  # 최대 TTL 설정
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"  # 지리적 제한 없음
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # 기본 CloudFront 인증서 사용
  }

  web_acl_id = var.web_acl_id  # 웹 ACL ID 설정

  tags = {
    Environment = var.environment  # 태그에 환경 정보 설정
    Project     = var.project  # 태그에 프로젝트 정보 설정
  }
}
