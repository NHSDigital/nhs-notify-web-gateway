resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${local.csi}-security-headers-policy"

  remove_headers_config {
    items {
      header = "x-powered-by"
    }
    items {
      header = "access-control-allow-origin"
    }
  }

  security_headers_config {
    content_security_policy {
      content_security_policy = "base-uri 'self'; form-action 'self'; frame-ancestors 'none'; default-src 'none'; connect-src 'self'; font-src 'self' https://assets.nhs.uk; img-src 'self'; script-src 'self'; style-src 'self'; upgrade-insecure-requests"
      override                = false
    }
    content_type_options {
      # micro-frontend middleware must insert an overriding policy due to nextjs inline scripts
      override = true
    }
    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }

  custom_headers_config {
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
      header   = "Permissions-Policy"
      override = false
      value    = "geolocation=(), microphone=(), camera=(), payment=(), fullscreen=()"
    }
  }
}
