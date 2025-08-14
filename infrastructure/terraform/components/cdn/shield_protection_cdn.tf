resource "aws_shield_protection" "cdn" {
  name         = "${local.csi}-cdn-protection"
  resource_arn = aws_cloudfront_distribution.main.arn

  tags = {
    Environment = var.environment
  }
}
