module "s3bucket_lambda_artefacts" {
  source = "../../modules/s3bucket"
  providers = {
    aws = aws.us-east-1
  }

  name = "lambda-artefacts"

  aws_account_id = var.aws_account_id
  region         = "us-east-1"
  project        = var.project
  environment    = var.environment
  component      = var.component

  acl           = "private"
  force_destroy = false
  versioning    = true

  lifecycle_rules = [
    {
      prefix  = ""
      enabled = true

      noncurrent_version_transition = [
        {
          noncurrent_days = "30"
          storage_class   = "STANDARD_IA"
        }
      ]

      noncurrent_version_expiration = {
        noncurrent_days = "90"
      }

      abort_incomplete_multipart_upload = {
        days = "1"
      }
    }
  ]

  policy_documents = [
    data.aws_iam_policy_document.s3bucket_lambda_artefacts.json
  ]

  public_access = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }


  default_tags = {
    Name = "Lambda function artefact bucket"
  }
}

data "aws_iam_policy_document" "s3bucket_lambda_artefacts" {
  statement {
    sid    = "DontAllowNonSecureConnection"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      module.s3bucket_lambda_artefacts.arn,
      "${module.s3bucket_lambda_artefacts.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      module.s3bucket_lambda_artefacts.arn,
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToGet"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.s3bucket_lambda_artefacts.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
  }
}