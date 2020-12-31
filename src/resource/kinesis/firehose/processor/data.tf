data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "cwl_compress_to_kinesis_lambda_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = ["arn:aws:firehose:ap-northeast-1:${data.aws_caller_identity.self.account_id}:deliverystream/cwl-transfer-slack-sample-stream"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.self.account_id}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/cwl-compress-to-kinesis:*"]
  }
}

data "archive_file" "cwl_compress_to_kinesis" {
  type        = "zip"
  source_dir  = "function/"
  output_path = "lambda_function.zip"
}