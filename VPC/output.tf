output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "VPC_id"
}

output "aws_subnet_name" {
  value = aws_subnet.app_subnet.name
  description = "application_subent_name"
}