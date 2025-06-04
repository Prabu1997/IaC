variable "ami_image_id" {
  default = ""
}

variable "availability_zone" {
  default = ""
}
variable "instance_name" {
  default = ""
}
variable "instance_type" {
  default = ""
}
variable "iam_instance_profile" {
  default = ""
}
variable "key_name" {
  default = ""
}
variable "vpc_security_group_ids" {
  default = ["",""]
}
variable "template_name" {
  default = ""
}
variable "availability_zones" {
  default = ["us-east-1","us-east-2"]
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
  default = ["subnet-1","subnet_2"]
}

variable "asg_health_check_type" {
  default = "ec2"
}

variable "aws_elb_arn" {
  default = "ARN"
}