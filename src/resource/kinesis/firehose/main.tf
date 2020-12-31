provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_kinesis_firehose_delivery_stream" "cwl-transfer-s3" {
  name        = local.cwl_transfer_s3_firehose["name"]
  destination = local.cwl_transfer_s3_firehose["destination"]
  extended_s3_configuration {
    role_arn            = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["role_arn"]
    bucket_arn          = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["bucket_arn"]
    prefix              = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["prefix"]
    error_output_prefix = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["error_output_prefix"]
    buffer_size         = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["buffer_size"]
    buffer_interval     = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["buffer_interval"]
    compression_format  = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["compression_format"]
    processing_configuration {
      enabled = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["processing_configuration"]["enabled"]

      processors {
        type = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["processing_configuration"]["processors"]["type"]

        parameters {
          parameter_name  = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["processing_configuration"]["processors"]["parameters"]["parameter_name"]
          parameter_value = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["processing_configuration"]["processors"]["parameters"]["parameter_value"]
        }
      }
    }
    cloudwatch_logging_options {
      enabled         = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["cloudwatch_logging_options"]["enabled"]
      log_group_name  = aws_cloudwatch_log_group.firehose-cwl-log-group.name
      log_stream_name = aws_cloudwatch_log_stream.firehose-cwl-log-stream.name
    }
    s3_backup_mode = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["s3_backup_mode"]
  }

  tags = {
    Name = local.cwl_transfer_s3_firehose["name"]
  }
}