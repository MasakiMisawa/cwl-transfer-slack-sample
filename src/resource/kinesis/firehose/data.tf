data "aws_caller_identity" "self" {}

data "terraform_remote_state" "s3" {
  backend = "local"

  config = {
    path = "../../s3/terraform.tfstate"
  }
}

data "terraform_remote_state" "lambda" {
  backend = "local"

  config = {
    path = "processor/terraform.tfstate"
  }
}

data "aws_iam_policy_document" "cwl_transfer_s3_firehose_policy" {
  statement {
    effect = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      data.terraform_remote_state.s3.outputs.bucket_arn,
      "${data.terraform_remote_state.s3.outputs.bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [data.terraform_remote_state.lambda.outputs.function_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.self.account_id}:log-group:/aws/kinesisfirehose/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = ["arn:aws:kinesis:ap-northeast-1:${data.aws_caller_identity.self.account_id}:stream/%FIREHOSE_STREAM_NAME%"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:ap-northeast-1:${data.aws_caller_identity.self.account_id}:key/%SSE_KEY_ID%"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["kinesis.ap-northeast-1.amazonaws.com"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:ap-northeast-1:${data.aws_caller_identity.self.account_id}:key/%SSE_KEY_ID%"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values   = ["arn:aws:kinesis:ap-northeast-1:${data.aws_caller_identity.self.account_id}:stream/%FIREHOSE_STREAM_NAME%"]
    }
  }
}