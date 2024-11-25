##
# Basic Required Variables for tfscaffold Components
##

variable "project" {
  type        = string
  description = "The name of the tfscaffold project"
}

variable "environment" {
  type        = string
  description = "The name of the tfscaffold environment"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID (numeric)"
}

variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "group" {
  type        = string
  description = "The group variables are being inherited from (often synonmous with account short-name)"
}

##
# tfscaffold variables specific to this component
##

# This is the only primary variable to have its value defined as
# a default within its declaration in this file, because the variables
# purpose is as an identifier unique to this component, rather
# then to the environment from where all other variables come.
variable "component" {
  type        = string
  description = "The variable encapsulating the name of this component"
  default     = "cdn"
}

variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all taggable resources within the component"
  default     = {}
}

##
# Variables specific to the "dnsroot"component
##

variable "kms_deletion_window" {
  type        = string
  description = "When a kms key is deleted, how long should it wait in the pending deletion state?"
  default     = "30"
}

variable "log_level" {
  type        = string
  description = "The log level to be used in lambda functions within the component. Any log with a lower severity than the configured value will not be logged: https://docs.python.org/3/library/logging.html#levels"
  default     = "INFO"
}

variable "log_retention_in_days" {
  type        = number
  description = "The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite"
  default     = 0
}

variable "parent_acct_environment" {
  type        = string
  description = "Name of the environment responsible for the acct resources used, affects things like DNS zone. Useful for named dev environments"
  default     = "main"
}

variable "force_lambda_code_deploy" {
  type        = bool
  description = "If the lambda package in s3 has the same commit id tag as the terraform build branch, the lambda will not update automatically. Set to True if making changes to Lambda code from on the same commit for example during development"
  default     = false
}

variable "waf_rate_limit_cdn" {
  type        = number
  description = "The rate limit is the maximum number of CDN requests from a single IP address that are allowed in a five-minute period"
  default     = 20000
}

variable "amplify_microservice_routes" {
  type = list(object({
    service_prefix  = string,
    root_dns_record = string,
  }))
  description = "An object representing the amplify microservice routing configration"
  default     = []
}

variable "cdn_sans" {
  type        = list(string)
  description = "Aliases to associate with CDN"
}

variable "cms_origin" {
  type = object({
    domain_name = string,
    origin_path = string,
    origin_id   = string
  })
  description = "Object to specifiy static domains for CDN"
  default = {
    domain_name = "nhsdigital.github.io"
    origin_path = "/nhs-notify-web-cms-dev"
    origin_id   = "github-nhs-notify-web-cms"
  }
}