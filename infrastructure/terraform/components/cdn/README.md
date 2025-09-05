<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
<!-- vale off -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.7 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AMPLIFY_BASIC_AUTH_SECRET"></a> [AMPLIFY\_BASIC\_AUTH\_SECRET](#input\_AMPLIFY\_BASIC\_AUTH\_SECRET) | Secret key/password to use for amplify microservice headers - This is entended to be read from CI variables and not commited to any codebase | `string` | `"unset"` | no |
| <a name="input_amplify_microservice_routes"></a> [amplify\_microservice\_routes](#input\_amplify\_microservice\_routes) | An object representing the amplify microservice routing configuration | <pre>list(object({<br/>    service_prefix  = string,<br/>    service_csi     = string,<br/>    root_dns_record = string,<br/>  }))</pre> | `[]` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_cdn_sans"></a> [cdn\_sans](#input\_cdn\_sans) | Aliases to associate with CDN | `list(string)` | `[]` | no |
| <a name="input_cms_origin"></a> [cms\_origin](#input\_cms\_origin) | Object to specify static domains for CDN | <pre>object({<br/>    domain_name = string,<br/>    origin_path = string,<br/>    origin_id   = string<br/>  })</pre> | <pre>{<br/>  "domain_name": "nhsdigital.github.io",<br/>  "origin_id": "github-nhs-notify-web-cms",<br/>  "origin_path": "/nhs-notify-web-cms-dev"<br/>}</pre> | no |
| <a name="input_component"></a> [component](#input\_component) | The variable encapsulating the name of this component | `string` | `"cdn"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_enable_github_actions_ip_access"></a> [enable\_github\_actions\_ip\_access](#input\_enable\_github\_actions\_ip\_access) | Should the Github actions runner IP addresses be permitted access to this distribution. This should not be enabled in production environments | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_force_lambda_code_deploy"></a> [force\_lambda\_code\_deploy](#input\_force\_lambda\_code\_deploy) | If the lambda package in s3 has the same commit id tag as the terraform build branch, the lambda will not update automatically. Set to True if making changes to Lambda code from on the same commit for example during development | `bool` | `false` | no |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | n/a | yes |
| <a name="input_kms_deletion_window"></a> [kms\_deletion\_window](#input\_kms\_deletion\_window) | When a kms key is deleted, how long should it wait in the pending deletion state? | `string` | `"30"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | The log level to be used in lambda functions within the component. Any log with a lower severity than the configured value will not be logged: https://docs.python.org/3/library/logging.html#levels | `string` | `"INFO"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite | `number` | `0` | no |
| <a name="input_parent_acct_environment"></a> [parent\_acct\_environment](#input\_parent\_acct\_environment) | Name of the environment responsible for the acct resources used, affects things like DNS zone. Useful for named dev environments | `string` | `"main"` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_shared_infra_account_id"></a> [shared\_infra\_account\_id](#input\_shared\_infra\_account\_id) | The AWS Account ID of the shared infrastructure account | `string` | `"000000000000"` | no |
| <a name="input_template_files_origin_domain_name"></a> [template\_files\_origin\_domain\_name](#input\_template\_files\_origin\_domain\_name) | Domain name for template file download origin | `string` | n/a | yes |
| <a name="input_waf_rate_limit_cdn"></a> [waf\_rate\_limit\_cdn](#input\_waf\_rate\_limit\_cdn) | The rate limit is the maximum number of CDN requests from a single IP address that are allowed in a five-minute period | `number` | `20000` | no |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-kms.zip | n/a |
| <a name="module_lambda_rewrite_origin_branch_requests"></a> [lambda\_rewrite\_origin\_branch\_requests](#module\_lambda\_rewrite\_origin\_branch\_requests) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-lambda.zip | n/a |
| <a name="module_lambda_rewrite_viewer_trailing_slashes"></a> [lambda\_rewrite\_viewer\_trailing\_slashes](#module\_lambda\_rewrite\_viewer\_trailing\_slashes) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-lambda.zip | n/a |
| <a name="module_s3bucket_cf_logs"></a> [s3bucket\_cf\_logs](#module\_s3bucket\_cf\_logs) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-s3bucket.zip | n/a |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_aliases"></a> [cloudfront\_distribution\_aliases](#output\_cloudfront\_distribution\_aliases) | Cloudfront distribution custom alias URLs |
| <a name="output_cloudfront_distribution_url"></a> [cloudfront\_distribution\_url](#output\_cloudfront\_distribution\_url) | Cloudfront distribution URL |
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
