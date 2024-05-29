resource "aws_cloudfront_origin_access_identity" "static_assets" {
  comment = "CaaS ${var.parameter_bundle.environment} - Used to access the s3 content for the ${var.module} static assets bucket"
}
