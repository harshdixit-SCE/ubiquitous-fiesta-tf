terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Bootstrap uses local state — it creates the remote backend,
  # so it cannot use it itself.
}

provider "aws" {
  region = var.aws_region
}
