# This code was originally developed with Terraform v0.11.11
terraform {
  required_version = "~> 0.11.11"
}

# This code was originally developed with AWS provider v1.55
provider "aws" {
  version = "~> 1.55"

  region = "${ var.region }"
}
