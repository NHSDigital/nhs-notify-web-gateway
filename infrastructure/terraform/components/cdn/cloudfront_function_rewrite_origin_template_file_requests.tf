resource "aws_cloudfront_function" "rewrite_origin_template_file_requests" {
  provider = aws.us-east-1

  name    = "${local.csi}-rewrite-origin-template-file-requests"
  comment = "A function for rewriting the request path on template file download origin requests"
  runtime = "cloudfront-js-2.0"
  code    = file("${local.aws_lambda_functions_dir_path}/rewrite-origin-template-file-requests/src/index.js")
}
