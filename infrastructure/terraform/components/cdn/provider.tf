provider "aws" {
  region = var.region

  default_tags {
    tags = local.default_tags
  }
}


# Provider specifically for deploying to us-east-1, e.g. for cloudfront, ACM, etc.
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = local.default_tags
  }
}

provider "github" {
  owner = "NHSDigital"
}
