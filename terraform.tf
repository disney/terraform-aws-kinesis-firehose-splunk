# This code was originally developed with Terraform v0.11.11
terraform {
  required_version = ">= 0.12"
}

# This code was originally developed with AWS provider v1.55
provider "aws" {
  version = "~> 2.7"

  region = var.region
}

