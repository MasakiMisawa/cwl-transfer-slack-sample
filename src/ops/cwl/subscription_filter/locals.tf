locals {
  cwl_transfer_firehose_iam_role = {
    role_name   = "CWLTransferFirehoseSubscriptionFilterRole"
    policy_name = "CWLTransferFirehoseSubscriptionFilterPolicy"
    policy      = data.aws_iam_policy_document.cwl_transfer_firehose_subscription_filter_policy.json
    identifier  = "logs.ap-northeast-1.amazonaws.com"
  }

  cwl_transfer_firehose_subscription_filter = {
    name            = "cwl-transfer-slack-sample-function-subscription-filter"
    role_arn        = module.cwl_transfer_firehose_iam_role.iam_role_arn
    log_group_name  = "/aws/lambda/cwl-transfer-slack-sample-function"
    filter_pattern  = "?Error ?ERROR"
    destination_arn = data.terraform_remote_state.firehose.outputs.stream_arn
    distribution    = "ByLogStream"
  }
}