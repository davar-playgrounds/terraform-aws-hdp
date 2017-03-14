# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true" # security ?
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.default.id}"
}

# EIP associated w/ NAT GW
resource "aws_eip" "nat" {
  vpc = true
}

# Create NAT Gateway for instance on private network to get internet access  
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_key_pair" "auth" {
  key_name   = "${lookup(var.key_name, var.aws_region)}"
  public_key = "${file(lookup(var.public_key_path, var.aws_region))}"
}