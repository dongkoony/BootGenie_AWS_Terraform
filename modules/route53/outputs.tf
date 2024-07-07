# ./modules/route53/outputs.tf

output "route53_zone_id" {
  description = "생성된 Route53 호스티드 존의 ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Route53 호스티드 존의 네임서버 목록"
  value       = aws_route53_zone.main.name_servers
}

output "domain_name" {
  description = "설정된 도메인 이름"
  value       = var.domain_name
}

output "www_record_name" {
  description = "생성된 www 서브도메인 레코드의 전체 이름"
  value       = aws_route53_record.web.name
}

output "apex_record_name" {
  description = "생성된 apex 도메인 레코드의 전체 이름"
  value       = aws_route53_record.apex.name
}
