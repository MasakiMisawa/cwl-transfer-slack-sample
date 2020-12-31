locals {
  cwl_transfer_s3_iam_role = {
    role_name   = "CWLTransferS3FirehoseRole"
    policy_name = "CWLTransferS3FirehosePolicy"
    policy      = data.aws_iam_policy_document.cwl_transfer_s3_firehose_policy.json
    identifier  = "firehose.amazonaws.com"
  }

  cwl_transfer_s3_firehose = {
    name        = "cwl-transfer-s3-sample-stream"
    destination = "extended_s3"
    extended_s3_configuration = {
      role_arn            = module.cwl_transfer_s3_iam_role.iam_role_arn
      bucket_arn          = data.terraform_remote_state.s3.outputs.bucket_arn
      prefix              = "lambda/"
      error_output_prefix = "error/lambda/"
      buffer_size         = 5
      buffer_interval     = 300
      compression_format  = "GZIP"
      processing_configuration = {
        enabled = true
        processors = {
          type = "Lambda"
          parameters = {
            parameter_name  = "LambdaArn"
            parameter_value = data.terraform_remote_state.lambda.outputs.function_arn
          }
        }
      }
      cloudwatch_logging_options = {
        enabled         = true
        log_group_name  = "/aws/kinesisfirehose/cwl-transfer-s3-sample-stream/"
        log_stream_name = "S3Delivery"
      }
      s3_backup_mode = "Disabled"
    }
  }
}