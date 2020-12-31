provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "cwl-transfer-slack-bukcet" {
  bucket        = local.cwl_transfer_slack_bukcet["bucket"]
  acl           = local.cwl_transfer_slack_bukcet["acl"]
  force_destroy = local.cwl_transfer_slack_bukcet["force_destroy"]
  versioning {
    enabled    = local.cwl_transfer_slack_bukcet["versioning"]["enabled"]
    mfa_delete = local.cwl_transfer_slack_bukcet["versioning"]["mfa_delete"]
  }

  tags = {
    Name = local.cwl_transfer_slack_bukcet["bucket"]
  }
}

resource "aws_s3_bucket_public_access_block" "cwl-transfer-slack-bukcet-block-public-access" {
  bucket = aws_s3_bucket.cwl-transfer-slack-bukcet.id

  block_public_acls       = local.cwl_transfer_slack_bukcet["block_public_acls"]
  block_public_policy     = local.cwl_transfer_slack_bukcet["block_public_policy"]
  ignore_public_acls      = local.cwl_transfer_slack_bukcet["ignore_public_acls"]
  restrict_public_buckets = local.cwl_transfer_slack_bukcet["restrict_public_buckets"]
}