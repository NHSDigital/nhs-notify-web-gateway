terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.13.1"
      configuration_aliases = [aws.us-east-1]
    }
  }

  required_version = ">= 1.8.1"
}
