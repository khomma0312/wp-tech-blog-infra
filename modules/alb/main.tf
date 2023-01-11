resource "aws_lb" "alb" {
    name = "${var.project_name}-alb"
    load_balancer_type = "application"
    subnets = [ for subnet in var.public_subnets : subnet.id ]
    security_groups = [ var.security_group_id ]
}

resource "aws_lb_listener" "ec2_http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_listener" "ec2_https" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = var.ssl_certificate_arn

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            status_code  = "404"
        }
    }
}

resource "aws_lb_listener_rule" "https_forward_rule" {
    listener_arn = aws_lb_listener.ec2_https.arn
    priority     = 1

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.ec2_https.arn
    }

    condition {
        http_header {
            http_header_name = "x-cf-header-secret"
            values = [ var.cf_header_secret_value ]
        }
    }
}

resource "aws_lb_target_group" "ec2_https" {
    name = "${var.project_name}-tg"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id

    health_check {
        enabled = true
        matcher = 200
        path = "/"
    }
}

resource "aws_lb_target_group_attachment" "ec2" {
    count            = length(var.instance_ids)
    target_group_arn = aws_lb_target_group.ec2_https.arn
    target_id        = var.instance_ids[count.index]
    port             = 80
}

data "aws_route53_zone" "web_site" {
    name         = var.domain_name
    private_zone = false
}

resource "aws_route53_record" "alb" {
    zone_id = data.aws_route53_zone.web_site.zone_id
    name    = "alb.${data.aws_route53_zone.web_site.name}"
    type    = "A"

    alias {
        name                   = aws_lb.alb.dns_name
        zone_id                = aws_lb.alb.zone_id
        evaluate_target_health = true
    }
}
