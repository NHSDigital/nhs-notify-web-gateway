<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
<!-- vale off -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.50 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_budget_amount"></a> [budget\_amount](#input\_budget\_amount) | The budget amount in USD for the account | `number` | `500` | no |
| <a name="input_component"></a> [component](#input\_component) | The variable encapsulating the name of this component | `string` | `"acct"` | no |
| <a name="input_cost_alarm_recipients"></a> [cost\_alarm\_recipients](#input\_cost\_alarm\_recipients) | A list of email addresses to receive alarm notifications | `list(string)` | `[]` | no |
| <a name="input_cost_anomaly_threshold"></a> [cost\_anomaly\_threshold](#input\_cost\_anomaly\_threshold) | The threshold percentage for cost anomaly detection | `number` | `10` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | n/a | yes |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite | `number` | `0` | no |
| <a name="input_observability_account_id"></a> [observability\_account\_id](#input\_observability\_account\_id) | The Observability Account ID that needs access | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | The service's root DNS root nameespace, like nonprod.nhsnotify.national.nhs.uk | `string` | `"nonprod.nhsnotify.national.nhs.uk"` | no |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3bucket_access_logs"></a> [s3bucket\_access\_logs](#module\_s3bucket\_access\_logs) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/s3bucket | v1.0.8 |
| <a name="module_s3bucket_lambda_artefacts"></a> [s3bucket\_lambda\_artefacts](#module\_s3bucket\_lambda\_artefacts) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/s3bucket | v1.0.8 |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zone"></a> [dns\_zone](#output\_dns\_zone) | n/a |
| <a name="output_s3_buckets"></a> [s3\_buckets](#output\_s3\_buckets) | n/a |
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
