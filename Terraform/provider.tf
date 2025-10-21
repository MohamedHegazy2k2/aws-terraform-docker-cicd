terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-complete-ci-cd-with-terraform-and-aws"
    key    = "terraform/state.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = var.region
}

