output "public_subnet" {
  value = "${aws_subnet.public.id}"
}

output "nat_gateway" {
  value = "${aws_nat_gateway.gw.id}"
}