resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${local.csi}-security-headers-policy"

  remove_headers_config {
    items {
      #  https://www.zaproxy.org/docs/alerts/10037/
      header = "x-powered-by"
    }
    items {
      # static pages have a wildcard value by default, removing this enforces 'same-origin'
      header = "access-control-allow-origin"
    }
    items {
      # this header is deprecated
      header = "x-xss-protection"
    }

    # s3 related
    items {
      # https://www.zaproxy.org/docs/alerts/10036/
      header = "server"
    }
    items {
      header = "x-amz-server-side-encryption"
    }
    items {
      header = "x-amz-server-side-encryption-aws-kms-key-id"
    }
    items {
      header = "x-amz-server-side-encryption-bucket-key-enabled"
    }
    items {
      header = "x-amz-version-id"
    }
  }

  security_headers_config {
    # https://www.zaproxy.org/docs/alerts/10038-1/
    content_security_policy {
      content_security_policy = "base-uri 'self'; form-action 'self'; frame-ancestors 'self'; default-src 'none'; connect-src 'self'; font-src 'self' https://assets.nhs.uk; img-src 'self'; script-src 'self'; style-src 'self'; upgrade-insecure-requests"
      override                = false
    }
    content_type_options {
      # micro-frontend middleware must insert an overriding policy due to nextjs inline scripts
      override = true
    }
    # https://www.zaproxy.org/docs/alerts/10035-1/
    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }

  custom_headers_config {
    # https://www.zaproxy.org/docs/alerts/90004/
    items {
      header   = "Cross-Origin-Resource-Policy"
      override = false
      value    = "same-origin"
    }

    items {
      header   = "Cross-Origin-Opener-Policy"
      override = false
      value    = "same-origin"
    }

    items {
      header   = "Cross-Origin-Embedder-Policy"
      override = false
      value    = "require-corp"
    }

    items {
      # https://www.zaproxy.org/docs/alerts/10063-1/
      header   = "Permissions-Policy"
      override = false
      value    = "geolocation=(), microphone=(), camera=(), payment=(), fullscreen=()"
    }
  }
}
