resource "aws_wafv2_web_acl_logging_configuration" "main" {
  provider = aws.us-east-1

  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}
