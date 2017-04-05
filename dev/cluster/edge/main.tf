provider "aws" {
  region = "${var.aws_region}"
}

# Load VPC related information
data "terraform_remote_state" "vpc" {
  backend  = "s3"

  config {
    bucket = "monolive-terraform-state"
    key    = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

# Load public subnet related information
data "terraform_remote_state" "public_network" {
  backend  = "s3"
  config {
    bucket = "monolive-terraform-state"
    key    = "dev/cluster/public_network/terraform.tfstate"
    region = "eu-west-2"
  }
}

# A security group for the public node so it is accessible via the web
resource "aws_security_group" "public" {
  name        = "public_node_sg"
  description = "public node SG"
  vpc_id      = "${data.terraform_remote_state.vpc.dev_vpc}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${var.user}"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${data.terraform_remote_state.vpc.auth_key}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id              = "${data.terraform_remote_state.public_network.public_subnet}"
  tags {
    Name = "edge-node"
  }
}