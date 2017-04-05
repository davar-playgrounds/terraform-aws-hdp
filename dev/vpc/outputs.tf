output "dev_vpc" {
  value = "${aws_vpc.dev.id}"
}

output "auth_key" {
  value = "${aws_key_pair.auth.id}"
}
