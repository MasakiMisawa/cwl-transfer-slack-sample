locals {
  cwl_compress_to_kinesis_iam_role = {
    role_name   = "CWLCompressToKinesisLambdaRole"
    policy_name = "CWLCompressToKinesisLambdaPolicy"
    policy      = data.aws_iam_policy_document.cwl_compress_to_kinesis_lambda_iam_policy.json
    identifier  = "lambda.amazonaws.com"
  }

  cwl_compress_to_kinesis_function = {
    function_name = "cwl-compress-to-kinesis"
    handler       = "lambda_function.handler"
    role          = module.cwl_compress_to_kinesis_iam_role.iam_role_arn
    runtime       = "python3.8"

    filename         = data.archive_file.cwl_compress_to_kinesis.output_path
    source_code_hash = data.archive_file.cwl_compress_to_kinesis.output_base64sha256

    memory_size = 128
    timeout     = 180
  }
}