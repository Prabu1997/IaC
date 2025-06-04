variable "vpc_id" {
  description = "VPC ID"
  default = "vpc-123"
}

variable "security_groups_id" {
  
}

variable "ami_image_id" {
  default = "ami-123"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "iam_instance_role" {
  default = "iam:arn:role"
}

variable "instance_name" {
  default = "firewall"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "desired_capacity" {
  default = "2"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "3"
}

variable "subnet_ids" {
  default = [sub-1,subnet_2]
}

variable "asg_health_check_type" {
  default = "ec2"
}