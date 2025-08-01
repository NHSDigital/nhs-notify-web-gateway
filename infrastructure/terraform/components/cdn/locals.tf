locals {
  aws_lambda_functions_dir_path = "../../../../lambdas"

  root_domain_name         = "${var.environment}.${local.acct.route53_zone_names["web-gw"]}" # e.g. [main|dev|abxy0].web-gateway.[dev|nonprod|prod].nhsnotify.national.nhs.uk
  root_domain_id           = local.acct.route53_zone_ids["web-gw"]
  root_domain_nameservers  = local.acct.route53_zone_nameservers["web-gw"]

  cloudfront_error_map = {
    "400" : { error_code : 400, response_page_path : "/error/400", response_code : "400" },
    "403" : { error_code : 403, response_page_path : "/error/403", response_code : "403" },
    "404" : { error_code : 404, response_page_path : "/error/404", response_code : "404" },
    "405" : { error_code : 405, response_page_path : "/error/400", response_code : "405" },
    "414" : { error_code : 414, response_page_path : "/error/400", response_code : "414" },
    "416" : { error_code : 416, response_page_path : "/error/400", response_code : "416" },
    "500" : { error_code : 500, response_page_path : "/error/500", response_code : "500" },
    "501" : { error_code : 501, response_page_path : "/error/500", response_code : "501" },
    "502" : { error_code : 502, response_page_path : "/error/400", response_code : "502" },
    "503" : { error_code : 503, response_page_path : "/error/503", response_code : "503" },
    "504" : { error_code : 504, response_page_path : "/error/400", response_code : "504" },
  }
}

