variable "vpc_cidr_block" {
  description = "VPC_CIDR_BLOCK"
  default = "10.1.1.0/24"
}

variable "vpc_name" {
  description = "VPC_NAME"
  default = "Application_VPC"
}

variable "app_subnet" {
  description = "Application subnet"
  default = {
    subnet_1 = {
        availability_zone = "us-east-1a"
        cidr_block = "10.1.1.1/25"
    }
    subnet_2 = {
        availability_zone = "us-east-1b"
        cidr_block = "10.1.1.128/25"
    }
  }
}