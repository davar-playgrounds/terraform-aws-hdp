output "private instance" {
  value = "${aws_instance.hdp.private_dns}"
}

