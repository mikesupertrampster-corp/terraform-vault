data "pagerduty_team" "platform" {
  name = var.service_team
}

data "pagerduty_escalation_policy" "platform" {
  name = var.service_team
}

resource "pagerduty_business_service" "vault" {
  name = local.name
  team = data.pagerduty_team.platform.id
}

resource "pagerduty_service" "vault" {
  name              = local.name
  escalation_policy = data.pagerduty_escalation_policy.platform.id
  alert_creation    = "create_alerts_and_incidents"
}

resource "pagerduty_service_dependency" "vault" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.vault.id
      type = pagerduty_business_service.vault.type
    }
    supporting_service {
      id   = pagerduty_service.vault.id
      type = pagerduty_service.vault.type
    }
  }
}

data "pagerduty_vendor" "datadog" {
  name = "Datadog"
}

resource "pagerduty_service_integration" "datadog" {
  name    = data.pagerduty_vendor.datadog.name
  service = pagerduty_service.vault.id
  vendor  = data.pagerduty_vendor.datadog.id
}

resource "datadog_integration_pagerduty_service_object" "testing_foo" {
  service_name = local.name
  service_key  = pagerduty_service_integration.datadog.integration_key
}