locals {
  slack_incomming_webhook_url = {
    name            = "cwl-transfer-slack-sample-webhook-url"
    type            = "SecureString"
    value           = "dummy"
    description     = "cwl-transfer-slack sample incomming webhook url."
    tier            = "Standard"
    overwrite       = false
    allowed_pattern = ""
  }
}