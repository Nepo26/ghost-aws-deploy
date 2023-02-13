# Set Up Terraform Cloud to manage its state
# This is not necessary to run the project
terraform {
  backend "s3" {
    bucket = "urutausec-terraform"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "urutausec-terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

}