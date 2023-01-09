output "alb_certificate_arn" {
    value = aws_acm_certificate_validation.cert.certificate_arn
}

output "cloudfront_certificate_arn" {
    value = aws_acm_certificate_validation.cert_cloudfront.certificate_arn
}
