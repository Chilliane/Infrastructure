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
}

#Create Public Subnet
resource "aws_subnet" "public" {
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.example.id
  cidr_block = element(var.subnets_cidr,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}
