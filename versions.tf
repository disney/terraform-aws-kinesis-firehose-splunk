terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.3.0, < 3.0.0"
    }
  }
}
