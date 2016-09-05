output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "internet_gateway_id" {
  value = "${aws_internet_gateway.gw.id}"
}

output "nat_gateway_az_1_id" {
  value = "${aws_nat_gateway.nat_gw_az_1.id}"
}

output "nat_gateway_az_2_id" {
  value = "${aws_nat_gateway.nat_gw_az_2.id}"
}

output "nat_gateway_az_3_id" {
  value = "${aws_nat_gateway.nat_gw_az_3.id}"
}

output "ssh_key_name" {
  value = "${aws_key_pair.keypair.key_name}"
}
