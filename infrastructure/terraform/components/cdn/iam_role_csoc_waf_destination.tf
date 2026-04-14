resource "aws_iam_role" "csoc_waf_destination" {
  count = var.csoc_log_forwarding ? 1 : 0
  name  = "${local.csi}-waf-log-subscription-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringLike = {
            "aws:SourceArn" = "arn:aws:logs:${var.region}:${var.aws_account_id}:*"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.us-east-1.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringLike = {
            "aws:SourceArn" = "arn:aws:logs:us-east-1:${var.aws_account_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "csoc_waf_destination" {
  count  = var.csoc_log_forwarding ? 1 : 0
  name   = "${local.csi}-waf-log-subscription-policy"
  role   = aws_iam_role.csoc_waf_destination[0].id
  policy = data.aws_iam_policy_document.csoc_waf_destination[0].json
}

# Adding this to avoid first time deployment issues with subscription filter creation before the IAM role and policy are fully propagated.
# This is a workaround for an eventual consistency issue in AWS IAM.
resource "time_sleep" "csoc_waf_destination_iam_propagation" {
  count           = var.csoc_log_forwarding ? 1 : 0
  create_duration = "15s"

  depends_on = [
    aws_iam_role_policy.csoc_waf_destination,
  ]
}

data "aws_iam_policy_document" "csoc_waf_destination" {
  count = var.csoc_log_forwarding ? 1 : 0
  statement {
    sid    = "AllowPutLogEvents"
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = [
      local.csoc_waf_log_destination_arn_us,
    ]
  }
}
