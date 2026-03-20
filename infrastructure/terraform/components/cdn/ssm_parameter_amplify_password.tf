resource "aws_ssm_parameter" "amplify_basic_auth_secret" {
  count = var.AMPLIFY_BASIC_AUTH_SECRET != "unset" ? 1 : 0

  name        = "/${local.csi}/amplify_basic_auth_secret"
  description = "The Basic Auth password used for the amplify app. This parameter is sourced from Github Environment variables"

  type  = "SecureString"
  value = var.AMPLIFY_BASIC_AUTH_SECRET
}
