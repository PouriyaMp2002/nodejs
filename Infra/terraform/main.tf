terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.Region
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}
