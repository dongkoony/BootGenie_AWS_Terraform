# ./modules/acm/outputs.tf

output "cert_arn" {
  description = "발급된 ACM 인증서의 ARN"
  value       = aws_acm_certificate.cert.arn
}