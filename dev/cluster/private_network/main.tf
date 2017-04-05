data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "monolive-terraform-state"
    key    = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "public_network" {
  backend = "s3"

  config {
    bucket = "monolive-terraform-state"
    key    = "dev/cluster/public_network/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

# Grant the VPC internet access on its main route table
resource "aws_route_table" "private" {
  vpc_id = "${data.terraform_remote_state.vpc.dev_vpc}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${data.terraform_remote_state.public_network.nat_gateway}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "private" {
  vpc_id                  = "${data.terraform_remote_state.vpc.dev_vpc}"
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
}

# Security group for the cluster nodes
resource "aws_security_group" "cluster_sg" {
  name        = "cluster_sg"
  description = "HDP Cluster SG"
  vpc_id      = "${data.terraform_remote_state.vpc.dev_vpc}"

  # SSH access from public node
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  # Allow all internal traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.10.0/24"]

  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
