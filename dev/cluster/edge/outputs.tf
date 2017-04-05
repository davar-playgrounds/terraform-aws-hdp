output "public instance" {
  value = "${aws_instance.public.public_dns}"
}
