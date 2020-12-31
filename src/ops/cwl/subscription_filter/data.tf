data "terraform_remote_state" "firehose" {
  backend = "local"

  config = {
    path = "../../../resource/kinesis/firehose/terraform.tfstate"
  }
}

data "aws_iam_policy_document" "cwl_transfer_firehose_subscription_filter_policy" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [data.terraform_remote_state.firehose.outputs.stream_arn]
  }
}