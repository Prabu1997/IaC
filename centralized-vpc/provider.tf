terraform {
  required_providers {
    aws = {
        source = "/aws"
        version = "> 5.0"
    }
  }
}

provider "aws" {

}