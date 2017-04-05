output "private instance" {
  value = ["${aws_instance.master.*.private_dns}"]
}
