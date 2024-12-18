resource "aws_ssm_parameter" "amplify_basic_auth_secret" {
  count = var.amplify_basic_auth_secret != "unset" ? 1 : 0

  name  = "/${local.csi}/amplify_basic_auth_secret"
  type  = "String"
  value = var.amplify_basic_auth_secret
}
