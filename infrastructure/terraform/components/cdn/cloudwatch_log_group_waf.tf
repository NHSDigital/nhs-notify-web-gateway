resource "aws_cloudwatch_log_group" "waf" {
  provider = aws.us-east-1
  name     = "aws-waf-logs-${local.csi}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

resource "aws_cloudwatch_log_resource_policy" "waf" {
  provider        = aws.us-east-1
  policy_document = data.aws_iam_policy_document.waf_logging.json
  policy_name     = "webacl-policy-${local.csi}"

  depends_on = [
    aws_cloudwatch_log_group.waf,
    aws_wafv2_web_acl_logging_configuration.main,
  ]
}

data "aws_iam_policy_document" "waf_logging" {
  provider = aws.us-east-1
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.waf.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:us-east-1:${var.aws_account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(var.aws_account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

resource "aws_cloudwatch_log_subscription_filter" "waf_csoc" {
  provider        = aws.us-east-1
  count           = var.csoc_log_forwarding ? 1 : 0
  name            = aws_cloudwatch_log_group.waf.name
  role_arn        = aws_iam_role.csoc_waf_destination[0].arn
  log_group_name  = aws_cloudwatch_log_group.waf.name
  filter_pattern  = ""
  destination_arn = local.csoc_waf_log_destination_arn_us

  depends_on = [
    time_sleep.csoc_waf_destination_iam_propagation,
  ]
}
