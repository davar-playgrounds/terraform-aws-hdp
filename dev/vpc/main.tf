# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "dev" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"        # security ?
}

resource "aws_key_pair" "auth" {
  key_name   = "${lookup(var.key_name, var.aws_region)}"
  public_key = "${file(lookup(var.public_key_path, var.aws_region))}"
}
