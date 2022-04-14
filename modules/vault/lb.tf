resource "aws_lb_target_group" "vault" {
  name                 = var.name
  port                 = var.port
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 5
  vpc_id               = var.vpc_id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/v1/sys/health?standbyok=true&uninitcode=200&sealedcode=200"
  }
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.current.zone_id
  name    = "vault.${data.aws_route53_zone.current.name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener_rule" "vault" {
  listener_arn = data.aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.vault.name]
    }
  }
}