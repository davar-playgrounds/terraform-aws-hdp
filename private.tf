# Grant the VPC internet access on its main route table
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
  
}

# Create a subnet to launch our instances into
resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "private" {
  name        = "hdp_sg"
  description = "HDP Cluster SG"
  vpc_id      = "${aws_vpc.default.id}"

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
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow SSH access
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.private.id}"
}
