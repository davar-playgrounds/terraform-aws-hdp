output "private_subnet" {
  value = "${aws_subnet.private.id}"
}

output "cluster_sg" {
	value = "${aws_security_group.cluster_sg.id}"
}