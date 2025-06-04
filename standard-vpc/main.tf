#VPC BLOCk

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = Var.vpc_name
  }
}

#Public Subnet
resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.vpc.id
  for_each = var.app_subnet
  availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}

#Defalut RT
resource "aws_route_table" "application_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Application_Route_table"
  }
}

#Default Route
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.application_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

#internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet Gateway"
  }
}

#Application route table association
resource "aws_route_table_association" "application_subnet_RT" {
  route_table_id = aws_route_table.application_route_table.id
  for_each = aws_subnet.app_subnet
  subnet_id = each.value.id
}

#security Group

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}