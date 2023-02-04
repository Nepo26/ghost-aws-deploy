# Set Up Terraform Cloud to manage its state
# This is not necessary to run the project
terraform {
  backend "s3" {
    bucket = "urutausec-terraform"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "urutausec-terraform-state-lock"
    access_key = "AKIA3FBB6FP672TTYW6N"
    secret_key = "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"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

}