terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

data "aws_region" "current" {}

resource "datadog_synthetics_test" "vault" {
  name      = "Vault [${var.environment}]"
  tags      = ["service:vault", "env:${var.environment}"]
  status    = "live"
  type      = "api"
  subtype   = "http"
  locations = ["aws:${data.aws_region.current.name}"]
  #  message   = "Notify @pagerduty"

  request_definition {
    method = "GET"
    url    = "${var.addr}/v1/sys/health?standbyok=true&uninitcode=200&sealedcode=200"
  }

  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = 3000
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = 200
  }

  assertion {
    type     = "header"
    operator = "is"
    target   = "application/json"
    property = "content-type"
  }

  options_list {
    tick_every = 60 * 60

    monitor_options {
      renotify_interval = 0
    }
  }
}

#
resource "datadog_service_level_objective" "vault" {
  name        = datadog_synthetics_test.vault.name
  type        = "monitor"
  monitor_ids = [datadog_synthetics_test.vault.monitor_id]

  thresholds {
    timeframe = "7d"
    target    = 99.9
    warning   = 99.99
  }

  thresholds {
    timeframe = "30d"
    target    = 99.9
    warning   = 99.99
  }

  tags = datadog_synthetics_test.vault.tags
}
