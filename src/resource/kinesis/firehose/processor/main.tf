provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_lambda_function" "cwl-compress-to-firehose" {
  function_name = local.cwl_compress_to_kinesis_function["function_name"]
  handler       = local.cwl_compress_to_kinesis_function["handler"]
  role          = local.cwl_compress_to_kinesis_function["role"]
  runtime       = local.cwl_compress_to_kinesis_function["runtime"]

  filename         = local.cwl_compress_to_kinesis_function["filename"]
  source_code_hash = local.cwl_compress_to_kinesis_function["source_code_hash"]

  memory_size = local.cwl_compress_to_kinesis_function["memory_size"]
  timeout     = local.cwl_compress_to_kinesis_function["timeout"]

  tags = {
    Name = local.cwl_compress_to_kinesis_function["function_name"]
  }
}

resource "aws_lambda_alias" "cwl-compress-to-firehose-prod-alias" {
  name             = "Prod"
  description      = "${local.cwl_compress_to_kinesis_function["function_name"]} Prod alias."
  function_name    = aws_lambda_function.cwl-compress-to-firehose.arn
  function_version = "$LATEST"

  lifecycle {
    ignore_changes = [function_version]
  }
}