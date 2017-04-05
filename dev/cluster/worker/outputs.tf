output "private instance" {
  value = ["${aws_instance.worker.*.private_dns}"]
}
 