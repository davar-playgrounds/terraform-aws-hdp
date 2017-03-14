output "public instance" {
  value = "${aws_instance.public.public_dns}"
}

output "private instance" {
  value = "${aws_instance.hdp.private_dns}"
}

