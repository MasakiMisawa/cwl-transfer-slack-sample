provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_cloudwatch_log_subscription_filter" "cwl-transfer-firehose" {
  name            = local.cwl_transfer_firehose_subscription_filter["name"]
  role_arn        = local.cwl_transfer_firehose_subscription_filter["role_arn"]
  log_group_name  = local.cwl_transfer_firehose_subscription_filter["log_group_name"]
  filter_pattern  = local.cwl_transfer_firehose_subscription_filter["filter_pattern"]
  destination_arn = local.cwl_transfer_firehose_subscription_filter["destination_arn"]
  distribution    = local.cwl_transfer_firehose_subscription_filter["distribution"]
}