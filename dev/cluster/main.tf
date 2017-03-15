data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "monolive-terraform-state"
    key = "dev/vpc/terraform.tfstate"    
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "${var.aws_region}" 
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "private" {
  name        = "hdp_sg"
  description = "HDP Cluster SG"
  vpc_id      = "${data.terraform_remote_state.vpc.dev_vpc}"

  # SSH access from public node
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "hdp" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "centos"
  }
  instance_type = "t2.micro"

  # Grab the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${data.terraform_remote_state.vpc.auth_key}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${data.terraform_remote_state.vpc.private_subnet}"
}
