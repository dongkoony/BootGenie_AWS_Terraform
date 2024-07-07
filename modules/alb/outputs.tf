output "alb_dns_name" {
  description = "생성된 ALB의 DNS 이름"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "생성된 ALB의 호스팅 영역 ID"
  value       = aws_lb.this.zone_id
}

output "alb_arn" {
  description = "생성된 ALB의 ARN"
  value       = aws_lb.this.arn
}

output "alb_name" {
  description = "생성된 ALB의 이름"
  value       = aws_lb.this.name
}

output "target_group_web_arn" {
  description = "웹 서버용 대상 그룹의 ARN"
  value       = aws_lb_target_group.web.arn
}

output "target_group_app_arn" {
  description = "앱 서버용 대상 그룹의 ARN"
  value       = aws_lb_target_group.app.arn
}

output "http_listener_arn" {
  description = "HTTP 리스너의 ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS 리스너의 ARN"
  value       = aws_lb_listener.https.arn
}

output "security_group_id" {
  description = "ALB에 연결된 보안 그룹의 ID"
  value       = aws_security_group.alb.id
}

output "alb_full_name" {
  description = "ALB의 전체 이름 (DNS 이름)"
  value       = "http://${aws_lb.this.dns_name}"
}

output "alb_https_listener_port" {
  description = "HTTPS 리스너의 포트"
  value       = 443
}

output "alb_http_listener_port" {
  description = "HTTP 리스너의 포트"
  value       = 80
}
