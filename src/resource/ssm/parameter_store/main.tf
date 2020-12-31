provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_ssm_parameter" "slack-incomming-webhook-url" {
  name            = local.slack_incomming_webhook_url["name"]
  type            = local.slack_incomming_webhook_url["type"]
  value           = local.slack_incomming_webhook_url["value"]
  description     = local.slack_incomming_webhook_url["description"]
  tier            = local.slack_incomming_webhook_url["tier"]
  overwrite       = local.slack_incomming_webhook_url["overwrite"]
  allowed_pattern = local.slack_incomming_webhook_url["allowed_pattern"]

  tags = {
    Name = local.slack_incomming_webhook_url["name"]
  }

  lifecycle {
    ignore_changes = [value]
  }
}