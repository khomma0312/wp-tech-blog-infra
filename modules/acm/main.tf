provider "aws" {
    alias  = "virginia"
    region = "us-east-1"
}

data "aws_route53_zone" "web_site" {
    name         = var.domain_name
    private_zone = false
}

resource "aws_acm_certificate" "cert" {
    domain_name               = data.aws_route53_zone.web_site.name
    validation_method         = "DNS"
    subject_alternative_names = [
        format("*.%s", data.aws_route53_zone.web_site.name),
    ]
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_acm_certificate" "cert_cloudfront" {
    domain_name       = data.aws_route53_zone.web_site.name
    validation_method = "DNS"
    provider          = aws.virginia
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route53_record" "cert_validation" {
    for_each = {
        for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            type   = dvo.resource_record_type
            record = dvo.resource_record_value
        }
        if dvo.domain_name != format("*.%s", data.aws_route53_zone.web_site.name)
    }

    zone_id = data.aws_route53_zone.web_site.zone_id
    name    = each.value.name
    type    = each.value.type
    records = [each.value.record]
    ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
    certificate_arn         = aws_acm_certificate.cert.arn
    validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_acm_certificate_validation" "cert_cloudfront" {
    provider                = aws.virginia
    certificate_arn         = aws_acm_certificate.cert_cloudfront.arn
    validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
