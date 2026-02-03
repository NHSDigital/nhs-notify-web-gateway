resource "aws_wafv2_web_acl" "main" {
  provider = aws.us-east-1

  name        = local.csi
  description = "${var.environment} WAF"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "GithubActionsIPRestriction"
    priority = 10

    action {
      allow {}
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.github_actions_ipv4.arn
          }
        }

        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.github_actions_ipv6.arn
          }
        }
      }
    }

    visibility_config {
      metric_name                = "${local.csi}_gha_ip_restrictions_metric"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "GeoLocationTrafficWhitelist"
    priority = 20

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["GB"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${local.csi}_geo_location_whitelist"
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 30
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "GenericRFI_QUERYARGUMENTS"
          action_to_use {
            count {}
          }
        }
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}
          }
        }
        rule_action_override {
          name = "CrossSiteScripting_BODY"
          action_to_use {
            count {}
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.csi}_waf_aws_managed_common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BlockOversizedBodyOutsideUpload"
    priority = 35

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          label_match_statement {
            scope = "LABEL"
            key   = "awswaf:managed:aws:core-rule-set:SizeRestrictions_Body"
          }
        }
        statement {
          or_statement {
            statement {
              not_statement {
                statement {
                  regex_match_statement {
                    field_to_match {
                      uri_path {}
                    }
                    # only uri to allow >8kb body is /templates(~<dynamic environment>)/<create|upload|edit>-letter-template(/<id>)
                    regex_string = "^\\/templates(~[a-zA-Z0-9_\\-]{1,26})?\\/(create|upload|edit)\\-letter\\-template(\\/[a-z0-9\\-]*)?$"
                    text_transformation {
                      priority = 10
                      type     = "NONE"
                    }
                  }
                }
              }
            }
            statement {
              size_constraint_statement {
                comparison_operator = "GT"
                field_to_match {
                  body {}
                }
                # 6MB lambda payload limit
                size = 6291456
                text_transformation {
                  priority = 10
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${local.csi}_body_size_restriction"
    }
  }

  rule {
    name     = "BlockCrossSiteScriptingOutsideUpload"
    priority = 40

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          # Check if it has been flagged as XSS
          label_match_statement {
            scope = "LABEL"
            key   = "awswaf:managed:aws:core-rule-set:CrossSiteScripting_Body"
          }
        }
        statement {
          # Block unless all PDF upload conditions are met
          not_statement {
            statement {
              and_statement {
                statement {
                  # check it's the create/edit letters endpoint
                  regex_match_statement {
                    field_to_match {
                      uri_path {}
                    }
                    regex_string = "^\\/templates(~[a-zA-Z0-9_\\-]{1,26})?\\/(create|edit|upload)\\-letter\\-template(\\/[a-z0-9\\-]*)?$"
                    text_transformation {
                      priority = 10
                      type     = "NONE"
                    }
                  }
                }
                statement {
                  # Check if it's a multipart form upload
                  byte_match_statement {
                    field_to_match {
                      single_header {
                        name = "content-type"
                      }
                    }
                    positional_constraint = "CONTAINS"
                    search_string         = "multipart/form-data"
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
                statement {
                  # Check if the multi-part request contains a PDF content-type
                  byte_match_statement {
                    field_to_match {
                      body {}
                    }
                    positional_constraint = "CONTAINS"
                    search_string         = "Content-Type: application/pdf"
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
                statement {
                  # Check if the body has a pdf signature (magic bytes check)
                  # Note: some PDF (rarely) may not contain %PDF- this will prevent those files from being uploaded.
                  byte_match_statement {
                    field_to_match {
                      body {}
                    }
                    positional_constraint = "CONTAINS"
                    search_string         = "%PDF-"
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${local.csi}_xss_restriction"
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 45
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.csi}_waf_aws_managed_input"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 50
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SQLi_BODY"
          action_to_use {
            count {}
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.csi}_waf_aws_managed_sql"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BlockSQLInjectionOutsideUpload"
    priority = 55

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          # Check if it has been flagged as SQL Injection
          label_match_statement {
            scope = "LABEL"
            key   = "awswaf:managed:aws:sql-database:SQLi_Body"
          }
        }
        statement {
          # Block unless all PDF upload conditions are met
          not_statement {
            statement {
              and_statement {
                statement {
                  # check it's the create/edit letters endpoint
                  regex_match_statement {
                    field_to_match {
                      uri_path {}
                    }
                    regex_string = "^\\/templates(~[a-zA-Z0-9_\\-]{1,26})?\\/(create|edit|upload)\\-letter\\-template(\\/[a-z0-9\\-]*)?$"
                    text_transformation {
                      priority = 10
                      type     = "NONE"
                    }
                  }
                }
                statement {
                  # Check if it's a multipart form upload
                  byte_match_statement {
                    field_to_match {
                      single_header {
                        name = "content-type"
                      }
                    }
                    positional_constraint = "CONTAINS"
                    search_string         = "multipart/form-data"
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
                statement {
                  # Check if the multi-part request contains a PDF content-type
                  byte_match_statement {
                    field_to_match {
                      body {}
                    }
                    positional_constraint = "CONTAINS"
                    search_string         = "Content-Type: application/pdf"
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
                statement {
                  # Check if the body has a pdf signature (magic bytes check)
                  # Note: some PDF (rarely) may not contain %PDF- this will prevent those files from being uploaded.
                  byte_match_statement {
                    field_to_match {
                      body {}
                    }
                    positional_constraint = "CONTAINS"
                    search_string         = "%PDF-"
                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${local.csi}_sqli_restriction"
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 60
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.csi}_waf_aws_managed_reputation"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 100
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit_cdn
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.csi}_waf_rate_limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.csi}_waf"
    sampled_requests_enabled   = true
  }
}
