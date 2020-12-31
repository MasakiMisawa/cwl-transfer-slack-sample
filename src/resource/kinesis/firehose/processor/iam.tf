module "cwl_compress_to_kinesis_iam_role" {
  source      = "../../../../module/iam_role"
  role_name   = local.cwl_compress_to_kinesis_iam_role["role_name"]
  policy_name = local.cwl_compress_to_kinesis_iam_role["policy_name"]
  policy      = local.cwl_compress_to_kinesis_iam_role["policy"]
  identifier  = local.cwl_compress_to_kinesis_iam_role["identifier"]
}