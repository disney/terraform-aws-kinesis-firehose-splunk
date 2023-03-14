terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = ">= 2.3.0, < 3.0.0"
    }
  }
}
