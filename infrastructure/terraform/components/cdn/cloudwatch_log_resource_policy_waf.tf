
resource "aws_cloudwatch_log_resource_policy" "waf" {
  provider = aws.us-east-1

  policy_document = data.aws_iam_policy_document.waf.json
  policy_name     = "webacl-policy-${local.csi}"
}

data "aws_iam_policy_document" "waf" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.waf.arn}:*"]

    condition {
      test     = "ArnLike"
      values   = [
        "arn:aws:logs:${var.region}:${var.aws_account_id}",
        "arn:aws:logs:us-east-1:${var.aws_account_id}",
      ]
      variable = "aws:SourceArn"
    }

    condition {
      test     = "StringEquals"
      values   = [tostring(var.aws_account_id)]
      variable = "aws:SourceAccount"
    }
  }
}
