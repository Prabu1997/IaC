#VPC Configuration

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_bloc
  tags = {
    Name = Var.vpc_name
  }
}

resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  for_each = var.app_subnet
  availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "tgw_subnet" {
vpc_id = aws_vpc.main_vpc.id
for_each = var.tgw_subnet
availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = application_route_table
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

#IPS/IDS subnet
resource "aws_vpc" "inspection_vpc" {
  cidr_block = var.inspection_vpc_cidr_block
  tags = {
    Name = Var.inspection_vpc_name
  }
}

resource "aws_subnet" "firewall_subnet" {
  vpc_id = aws_vpc.inspection_vpc.id
  for_each = var.firewall_subnet
  availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "inspection_tgw_subnet" {
vpc_id = aws_vpc.inspection_vpc.id
for_each = var.inspection_tgw_subnet
availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  tags = {
    Name = each.key
  }
}

resource "aws_ec2_transit_gateway" "transit_gateway" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  description = "Transit Gateway"
  amazon_side_asn = "65001"
  dns_support = "disable"
  auto_accept_shared_attachments = "disable"
  multicast_support = "disable"
  vpn_ecmp_support = "enable"
}

#General Route table for the application VPC

resource "aws_ec2_transit_gateway_route_table" "general_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  tags = {
    Name = "General Route Table"
  }
}

#Inspection Route table
resource "aws_ec2_transit_gateway_route_table" "inspection_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  tags = {
    Name = "Insepction Route Table"
  }
}

# default route forward to inspection VPC
resource "aws_ec2_transit_gateway_route" "inspection_route" {
  transit_gateway_attachment_id = var.inspection_vpc_attachement
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.general_route_table.id
  destination_cidr_block = "0.0.0.0"
}

#Application vpc attachement
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachement" {
  vpc_id = aws_vpc.main_vpc.id
  for_each = aws_subnet.tgw_subnet.id
  subnet_ids = each.value
  transit_gateway_default_route_table_association = "disable"
  transit_gateway_default_route_table_propagation = "disable"
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

#inspection VPC attachement
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachement" {
  vpc_id = aws_vpc.inspection_vpc.id
  for_each = aws_subnet.inspection_tgw_subnet.id
  subnet_ids = each.value
  transit_gateway_default_route_table_association = "disable"
  transit_gateway_default_route_table_propagation = "disable"
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

# General Table association
resource "aws_ec2_transit_gateway_route_table_association" "general_association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachement.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.general_route_table.id
}

#inspection VPC for return traffic
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_propagation" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachement.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.general_route_table.id
}


## NOTE ###

##Ideal solution will be creating a inspection vpc and tgw attachement separatly and call those attachement in the transit gateway route table

##It will help us to reuse the module to deploy the VPC in all the account which attach to transit gateway