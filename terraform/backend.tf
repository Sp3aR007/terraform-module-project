terraform {
  backend "s3" {
    bucket = "sp3ar007-terraform-backend"
    key    = "statefiles/terraform.tfstate"
    region = "us-east-1"
  }
}