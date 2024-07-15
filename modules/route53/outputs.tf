# ./modules/route53/outputs.tf

output "domain_name" {
  description = "설정된 도메인 이름"
  value       = var.domain_name
}

output "www_record_name" {
  description = "생성된 www 서브도메인 레코드의 전체 이름"
  value       = aws_route53_record.www.name
}

output "apex_record_name" {
  description = "생성된 apex 도메인 레코드의 전체 이름"
  value       = aws_route53_record.apex.name
}