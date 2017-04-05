data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "monolive-terraform-state"
    key    = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "gw" {
  vpc_id = "${data.terraform_remote_state.vpc.dev_vpc}"
}

# EIP associated w/ NAT GW
resource "aws_eip" "nat" {
  vpc = true
}

# Create NAT Gateway for instance on private network to get internet access  
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "public" {
  vpc_id = "${data.terraform_remote_state.vpc.dev_vpc}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "public" {
  vpc_id                  = "${data.terraform_remote_state.vpc.dev_vpc}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}
