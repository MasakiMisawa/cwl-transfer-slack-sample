locals {
  cwl_transfer_slack_iam_role = {
    role_name   = "CWLTransferSlackLambdaRole"
    policy_name = "CWLTransferSlackLambdaPolicy"
    policy      = data.aws_iam_policy_document.cwl_transfer_slack_lambda_iam_policy.json
    identifier  = "lambda.amazonaws.com"
  }

  cwl_transfer_slack_function = {
    function_name = "cwl-transfer-slack"
    handler       = "lambda_function.lambda_handler"
    role          = module.cwl_transfer_slack_iam_role.iam_role_arn
    runtime       = "python3.8"

    filename         = data.archive_file.cwl_transfer_slack.output_path
    source_code_hash = data.archive_file.cwl_transfer_slack.output_base64sha256

    memory_size = 128
    timeout     = 300

    environment = {
      S3_REGION_NAME                       = "ap-northeast-1"
      SSM_SLACK_WEBHOOK_URL_PARAMETER_NAME = data.terraform_remote_state.ssm_slack_webhook_url.outputs.parameter_name
      SSM_REGION_NAME                      = "ap-northeast-1"
    }
  }

  cwl_transfer_slack_resource_policy = {
    statement_id   = "AllowExecutionFromS3Bucket"
    action         = "lambda:InvokeFunction"
    principal      = "s3.amazonaws.com"
    source_account = data.aws_caller_identity.self.account_id
    source_arn     = data.terraform_remote_state.s3.outputs.bucket_arn
  }

  cwl_transfer_slack_event_trigger = {
    bucket = data.terraform_remote_state.s3.outputs.bucket_name
    lambda_function = {
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "lambda"
      filter_suffix = ".gz"
    }
  }
}