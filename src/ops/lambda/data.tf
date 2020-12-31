data "aws_caller_identity" "self" {}

data "terraform_remote_state" "ssm_slack_webhook_url" {
  backend = "local"

  config = {
    path = "../../resource/ssm/parameter_store/terraform.tfstate"
  }
}

data "terraform_remote_state" "s3" {
  backend = "local"

  config = {
    path = "../../resource/s3/terraform.tfstate"
  }
}

data "aws_iam_policy_document" "cwl_transfer_slack_lambda_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      data.terraform_remote_state.s3.outputs.bucket_arn,
      "${data.terraform_remote_state.s3.outputs.bucket_arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.self.account_id}:parameter/${data.terraform_remote_state.ssm_slack_webhook_url.outputs.parameter_name}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.self.account_id}:key/*"]
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
    resources = ["arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/cwl-transfer-slack:*"]
  }
}

data "archive_file" "cwl_transfer_slack" {
  type        = "zip"
  source_dir  = "function/"
  output_path = "lambda_function.zip"
}