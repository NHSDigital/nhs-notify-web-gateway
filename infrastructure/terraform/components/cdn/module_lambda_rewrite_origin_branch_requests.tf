module "lambda_rewrite_origin_branch_requests" {
  source = "https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.29/terraform-lambda.zip"

  providers = {
    aws = aws.us-east-1
  }

  function_name = "rewrite-origin-branch-requests"
  description   = "A function for removing the request path on origin requests"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = "us-east-1"
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms.key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.lambda_rewrite_origin_branch_requests.json
  }

  function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts_us"]["id"]
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "rewrite-origin-branch-requests/src"
  function_include_common = true
  function_module_name    = "index"
  handler_function_name   = "handler"
  runtime                 = "nodejs20.x"
  memory                  = 128
  timeout                 = 5
  log_level               = var.log_level
  lambda_at_edge          = true

  force_lambda_code_deploy = var.force_lambda_code_deploy
  enable_lambda_insights   = false

  log_destination_arn       = local.destination_arn_us
  log_subscription_role_arn = local.acct.log_subscription_role_arn
}

data "aws_iam_policy_document" "lambda_rewrite_origin_branch_requests" {
  statement {
    sid    = "KMSPermissions"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      module.kms.key_arn,
    ]
  }
}
