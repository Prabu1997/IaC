variable "app_subnet" {
  default = {
    subnet_1 = {
        availability_zone = "us-east-1a"
        cidr_block = "10.1.1.0/24"
    }
  }
}

variable "tgw_subnet" {
  default = {
    subnet_1 = {
        availability_zone = "us-east-1a"
        cidr_block = "10.1.2.0/24"
    }
  }
}

variable "vpc_name" {
  default = "app_vpc"
}

variable "vpc_cidr_bloc" {
  default = "10.1.1.0/23"
}

variable "inspection_vpc_attachement" {
  default = "tgw-12323232"
}

#Firewall VPC

variable "firewall_subnet" {
  default = {
    subnet_1 = {
        availability_zone = "us-east-1a"
        cidr_block = "10.2.1.0/24"
    }
  }
}

variable "inspection_tgw_subnet" {
  default = {
    subnet_1 = {
        availability_zone = "us-east-1a"
        cidr_block = "10.2.2.0/24"
    }
  }
}

variable "inspection_name" {
  default = "app_vpc"
}

variable "inspection_vpc_cidr_block" {
  default = "10.1.1.0/23"
}
