output "alb_domain_name" {
    value = aws_route53_record.alb.name
}