# terraform block
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# provider block
provider "aws" {
   region = "ap-south-1"
}

# resource block
# VPC
resource "aws_vpc" "terraform-vpc" {
 cidr_block = "10.0.0.0/16"
 tags = {
  Name = "my-vpc"
  Owner = "sanjay"
  environment = "testing"
  DOC = "23/03/23"
 }
}

#public subnet
resource "aws_subnet" "public-sn" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public"
  }
}

# private subnet
resource "aws_subnet" "private-sn" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "private"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "igw"
  }
}


# Elastic ip

resource "aws_eip" "elastic" {
  vpc = true
  tags = {
    Name = "elasticIP"
  }
}


# NAT gateway

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.elastic.id
  subnet_id = aws_subnet.public-sn.id

tags = {
  Name = "NAT gateway"
 }
 depends_on =  [aws_internet_gateway.igw]
 }


# route table
# public RT
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Public-RT"
  }
}

# Private RT
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Private-RT"
  }
}

# Routes
resource "aws_route" "public-route" {
  route_table_id = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  depends_on = [aws_route_table.public-rt]
}

resource "aws_route" "private-route" {
  route_table_id = aws_route_table.private-rt.id
  destination_cidr_block = "10.0.1.0/24"
  gateway_id = aws_nat_gateway.natgw.id
  depends_on = [aws_route_table.private-rt]
}

# subnet association
# public subnet association

resource "aws_route_table_association" "public-association" {
  subnet_id = aws_subnet.public-sn.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-association" {
  subnet_id = aws_subnet.private-sn.id
  route_table_id = aws_route_table.private-rt.id
}
