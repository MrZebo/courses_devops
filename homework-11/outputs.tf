output "ip" {
  value = "${aws_instance.web.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.web.public_dns}"
}

#output "vpc_id" {
#  description = "The ID of the VPC"
#  value       = concat(aws_vpc.this.*.id, [""])[0]
#}
