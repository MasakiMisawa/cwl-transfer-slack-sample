resource "aws_cloudwatch_log_group" "firehose-cwl-log-group" {
  name = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["cloudwatch_logging_options"]["log_group_name"]
}

resource "aws_cloudwatch_log_stream" "firehose-cwl-log-stream" {
  name           = local.cwl_transfer_s3_firehose["extended_s3_configuration"]["cloudwatch_logging_options"]["log_stream_name"]
  log_group_name = aws_cloudwatch_log_group.firehose-cwl-log-group.name
}