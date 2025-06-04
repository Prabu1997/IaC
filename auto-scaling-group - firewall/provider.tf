terraform {
  required_providers {
    aws = {
        version = "> 5.0"
        source = "/aws"
    }
  }
}

provider "aws" {
  region = us-east-1 # region where you want to deploy the resources.
  alias = "Prod"  # Alias help us to pass the multiple accounts
}