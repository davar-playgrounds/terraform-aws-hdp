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
data "terraform_remote_state" "private_network" {
  backend  = "s3"
  config {
    bucket = "monolive-terraform-state"
    key    = "dev/cluster/private_network/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_instance" "master" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${var.user}"
  }
  count = "${var.master_nodes}"
  instance_type = "t2.micro"

  # Grab the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${data.terraform_remote_state.vpc.auth_key}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${data.terraform_remote_state.private_network.cluster_sg}"]
  subnet_id              = "${data.terraform_remote_state.private_network.private_subnet}"
  tags {
    Name = "master${count.index}"
  }
}
