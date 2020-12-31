output "bucket_arn" {
  value = aws_s3_bucket.cwl-transfer-slack-bukcet.arn
}

output "bucket_name" {
  value = aws_s3_bucket.cwl-transfer-slack-bukcet.id
}