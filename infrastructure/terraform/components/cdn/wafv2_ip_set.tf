resource "aws_wafv2_ip_set" "github_actions_ipv4" {
  provider = aws.us-east-1

  name               = "${local.csi}-github-actions-ipv4"
  description        = "Public references for github actions runner IP addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = data.github_ip_ranges.main.actions_ipv4
}

resource "aws_wafv2_ip_set" "github_actions_ipv6" {
  provider = aws.us-east-1

  name               = "${local.csi}-github-actions-ipv6"
  description        = "Public references for github actions runner IP addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = data.github_ip_ranges.main.actions_ipv6
}
