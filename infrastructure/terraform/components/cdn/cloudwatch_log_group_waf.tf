resource "aws_cloudwatch_log_group" "waf" {
  provider = aws.us-east-1

  name              = "aws-waf-logs-${local.csi}" # Mandatory prefix
  kms_key_id        = module.kms.key_arn
  retention_in_days = var.log_retention_in_days
}
