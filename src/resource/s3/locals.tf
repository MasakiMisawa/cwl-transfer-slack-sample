locals {
  cwl_transfer_slack_bukcet = {
    bucket        = "cwl-transfer-slack-sample-bucket"
    acl           = "private"
    force_destroy = false
    versioning = {
      enabled    = true
      mfa_delete = false
    }

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}