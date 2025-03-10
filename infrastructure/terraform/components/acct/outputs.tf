output "dns_zone" {
  value = {
    id          = aws_route53_zone.main.id
    name        = aws_route53_zone.main.name
    nameservers = aws_route53_zone.main.name_servers
  }
}

output "s3_buckets" {
  value = {
    access_logs = {
      arn    = module.s3bucket_access_logs.arn
      bucket = module.s3bucket_access_logs.bucket
      id     = module.s3bucket_access_logs.id
    }
    lambda_function_artefacts = {
      arn    = module.s3bucket_lambda_artefacts.arn
      bucket = module.s3bucket_lambda_artefacts.bucket
      id     = module.s3bucket_lambda_artefacts.id
    }
  }
}
