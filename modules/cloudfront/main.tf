resource "aws_cloudfront_distribution" "cdn" {
    aliases = [
        var.domain_name,
    ]

    enabled             = true
    price_class         = "PriceClass_All"
    wait_for_deployment = true

    origin {
        origin_id = "alb"
        domain_name = var.alb_domain_name
        custom_header {
            name = "x-cf-header-secret"
            value = var.cf_header_secret_value
        }
        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    default_cache_behavior {
        target_origin_id           = "alb"
        viewer_protocol_policy     = "redirect-to-https"

        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods  = ["GET", "HEAD"]
        compress        = true

        cache_policy_id = aws_cloudfront_cache_policy.static_content.id
        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    }

    ordered_cache_behavior {
        path_pattern           = "*.php"
        target_origin_id       = "alb"
        viewer_protocol_policy = "redirect-to-https"

        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods  = ["GET", "HEAD"]
        compress        = true

        cache_policy_id = data.aws_cloudfront_cache_policy.dynamic_content.id
        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    }

    ordered_cache_behavior {
        path_pattern           = "/wp-admin/*"
        target_origin_id       = "alb"
        viewer_protocol_policy = "redirect-to-https"

        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods  = ["GET", "HEAD"]
        compress        = true

        cache_policy_id = data.aws_cloudfront_cache_policy.dynamic_content.id
        origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    }

    viewer_certificate {
        acm_certificate_arn = var.ssl_certificate_arn
        ssl_support_method  = "sni-only"
    }
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
    name = "Managed-AllViewer"
}

data "aws_cloudfront_cache_policy" "dynamic_content" {
    name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_cache_policy" "static_content" {
    name        = "Static-Content-Policy"
    comment     = "Cache policy for static contents(Default TTL is 300)"
    default_ttl = 360
    max_ttl     = 360

    parameters_in_cache_key_and_forwarded_to_origin {
        enable_accept_encoding_gzip = true

        cookies_config {
            cookie_behavior = "none"
        }
        headers_config {
            header_behavior = "none"
        }
        query_strings_config {
            query_string_behavior = "none"
        }
    }
}

data "aws_route53_zone" "web_site" {
    name         = var.domain_name
    private_zone = false
}

resource "aws_route53_record" "cloudfront" {
    zone_id = data.aws_route53_zone.web_site.zone_id
    name    = data.aws_route53_zone.web_site.name
    type    = "A"

    alias {
        name                   = aws_cloudfront_distribution.cdn.domain_name
        zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
        evaluate_target_health = true
    }
}
