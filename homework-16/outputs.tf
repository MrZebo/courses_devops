#output "Centos_ips" {
#  value = "${aws_instance.centos.*.public_ip}"
#}

output "Ubuntu_ips" {
  value = "${aws_instance.ubuntu.*.public_ip}"
}

#output "Windows_ips" {
#  value = "${aws_instance.windows.*.public_ip}"
#}

#output "public_dns" {
#  value = "${aws_instance.web.public_dns}"
#}

#output "vpc_id" {
#  description = "The ID of the VPC"
#  value       = concat(aws_vpc.this.*.id, [""])[0]
#}
