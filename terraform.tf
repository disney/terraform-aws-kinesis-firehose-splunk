terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.7.0"

  region = var.region
}
