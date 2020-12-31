provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_lambda_function" "cwl-transfer-slack" {
  function_name = local.cwl_transfer_slack_function["function_name"]
  handler       = local.cwl_transfer_slack_function["handler"]
  role          = local.cwl_transfer_slack_function["role"]
  runtime       = local.cwl_transfer_slack_function["runtime"]

  filename         = local.cwl_transfer_slack_function["filename"]
  source_code_hash = local.cwl_transfer_slack_function["source_code_hash"]

  memory_size = local.cwl_transfer_slack_function["memory_size"]
  timeout     = local.cwl_transfer_slack_function["timeout"]

  environment {
    variables = {
      S3_REGION_NAME                       = local.cwl_transfer_slack_function["environment"]["S3_REGION_NAME"]
      SSM_SLACK_WEBHOOK_URL_PARAMETER_NAME = local.cwl_transfer_slack_function["environment"]["SSM_SLACK_WEBHOOK_URL_PARAMETER_NAME"]
      SSM_REGION_NAME                      = local.cwl_transfer_slack_function["environment"]["SSM_REGION_NAME"]
    }
  }

  tags = {
    Name = local.cwl_transfer_slack_function["function_name"]
  }
}

resource "aws_lambda_alias" "cwl-transfer-slack-prod-alias" {
  name             = "Prod"
  description      = "${local.cwl_transfer_slack_function["function_name"]} Prod alias."
  function_name    = aws_lambda_function.cwl-transfer-slack.arn
  function_version = "$LATEST"

  lifecycle {
    ignore_changes = [function_version]
  }
}

resource "aws_lambda_permission" "cwl-transfer-slack-resource-policy" {
  function_name  = aws_lambda_function.cwl-transfer-slack.function_name
  qualifier      = aws_lambda_alias.cwl-transfer-slack-prod-alias.name
  statement_id   = local.cwl_transfer_slack_resource_policy["statement_id"]
  action         = local.cwl_transfer_slack_resource_policy["action"]
  principal      = local.cwl_transfer_slack_resource_policy["principal"]
  source_account = local.cwl_transfer_slack_resource_policy["source_account"]
  source_arn     = local.cwl_transfer_slack_resource_policy["source_arn"]
}

resource "aws_s3_bucket_notification" "cwl-transfer-slack-event-trigger" {
  bucket = local.cwl_transfer_slack_event_trigger["bucket"]

  lambda_function {
    lambda_function_arn = aws_lambda_alias.cwl-transfer-slack-prod-alias.arn
    events              = local.cwl_transfer_slack_event_trigger["lambda_function"]["events"]
    filter_prefix       = local.cwl_transfer_slack_event_trigger["lambda_function"]["filter_prefix"]
    filter_suffix       = local.cwl_transfer_slack_event_trigger["lambda_function"]["filter_suffix"]
  }
}