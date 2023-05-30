terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraformVPC"
  }
}

#Variable for subnets
variable "subnets_cidr" {
	type = list
	default = ["10.0.1.0/24", "10.0.2.0/24"]
  #10.0.1.0/24 will be public , 10.0.2.0/24 will be private
}
#Variable name for the subnets
variable "subnet_names"{
  type = list 
  default = ["Public","Private"]
}


#Create Public Subnet
resource "aws_subnet" "subnet" {
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.example.id
  cidr_block = element(var.subnets_cidr,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "TerraformSubnet-${var.subnet_names[count.index]}"
  }
}

#Create Internet Gateways
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "TerraformInternetGateway"
  }
}

#Create public routing table
resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id #Provide connection to Internet
  }
  tags = {
    Name = "RouteTerraformPublic"
  }
}
#Create private routing table
resource "aws_route_table" "private_routing_table" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "RouteTerraformPrivate"
  }
}
# Create public Routing Table Association
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.subnet[0].id # Public subnet
  route_table_id = aws_route_table.public_routing_table.id
}

# Create private Routing Table Association
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.subnet[1].id # private subnet
  route_table_id = aws_route_table.private_routing_table.id
}
