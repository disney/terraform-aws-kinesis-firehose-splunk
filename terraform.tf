terraform {
  required_version = ">= 0.12.0, < 0.14.0"
}

provider "aws" {
  version = ">= 3.0, <= 3.11.0"

  region = var.region
}

