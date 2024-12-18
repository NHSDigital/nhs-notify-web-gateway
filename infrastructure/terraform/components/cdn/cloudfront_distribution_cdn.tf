resource "aws_cloudfront_distribution" "main" {
  provider = aws.us-east-1

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "NHS Notify CDN (${local.csi})"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-distributionconfig.html#cfn-cloudfront-distribution-distributionconfig-priceclass
  web_acl_id          = aws_wafv2_web_acl.main.arn

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  aliases = flatten([
    [
      local.root_domain_name,
    ],
    var.cdn_sans
  ])

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main.arn
    minimum_protocol_version = "TLSv1.2_2021" # Supports 1.2 & 1.3 - https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html
    ssl_support_method       = "sni-only"
  }

  logging_config {
    bucket          = module.s3bucket_cf_logs.bucket_regional_domain_name
    include_cookies = false
  }

  # CMS-Web Template origin
  origin {
    domain_name = var.cms_origin.domain_name
    origin_path = var.cms_origin.origin_path
    origin_id   = var.cms_origin.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
  }

  # Github Web-CMS behaviour
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    target_origin_id = "github-nhs-notify-web-cms"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
        event_type = "viewer-response"
        lambda_arn = module.lambda_rewrite_viewer_trailing_slashes.function_qualified_arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Amplify microservice routing
  dynamic "origin" {
    for_each = var.amplify_microservice_routes

    content {
      domain_name = origin.value.root_dns_record
      origin_id   = "${local.csi}-${origin.value.service_prefix}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols = [
          "TLSv1.2"
        ]
      }
      custom_header {
        name  = "x-amplify-base-url"
        value = origin.value.root_dns_record
      }

      dynamic "custom_header" {
        for_each = var.amplify_basic_auth_secret != "unset" ? [1] : []

        content {
          name  = "Authorization"
          value = aws_ssm_parameter.amplify_basic_auth_secret[0].value
        }
      }
    }
  }

  # Routes to account for branches like /auth~mybranch123
  dynamic "ordered_cache_behavior" {
    for_each = var.amplify_microservice_routes

    content {
      path_pattern = "/${ordered_cache_behavior.value.service_prefix}~*"
      allowed_methods = [
        "DELETE",
        "GET",
        "HEAD",
        "OPTIONS",
        "PATCH",
        "POST",
        "PUT",
      ]

      cached_methods = [
        "GET",
        "HEAD",
      ]

      forwarded_values {
        query_string = false
        headers      = ["Authorization"]
        cookies {
          forward = "none"
        }
      }

      lambda_function_association {
        event_type = "origin-request"
        lambda_arn = module.lambda_rewrite_origin_branch_requests.function_qualified_arn
      }

      target_origin_id       = "${local.csi}-${ordered_cache_behavior.value.service_prefix}"
      viewer_protocol_policy = "redirect-to-https"
      compress               = true
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.amplify_microservice_routes
    content {
      path_pattern = "/${ordered_cache_behavior.value.service_prefix}*"
      allowed_methods = [
        "DELETE",
        "GET",
        "HEAD",
        "OPTIONS",
        "PATCH",
        "POST",
        "PUT",
      ]

      cached_methods = [
        "GET",
        "HEAD",
      ]

      forwarded_values {
        query_string = false
        headers      = ["Authorization"]
        cookies {
          forward = "none"
        }
      }

      target_origin_id       = "${local.csi}-${ordered_cache_behavior.value.service_prefix}"
      viewer_protocol_policy = "redirect-to-https"
      compress               = true
    }
  }
}

