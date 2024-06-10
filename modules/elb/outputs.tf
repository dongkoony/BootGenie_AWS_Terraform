output "elb_dns_name" {
  value = aws_lb.web.dns_name
}

output "elb_zone_id" {
  value = aws_lb.web.zone_id
}

output "elb_arn" {
  value = aws_lb.web.arn
}