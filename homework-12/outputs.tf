output "public_ip_of_private_instance" {
  value = "${aws_instance.web.private_ip}"
}

output "public_ip_of_public_instance" {
  value = "${aws_instance.bastion.public_ip}"
}


