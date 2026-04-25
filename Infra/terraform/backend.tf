terraform {
  backend "s3" {
    bucket = "pouriya-company"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
