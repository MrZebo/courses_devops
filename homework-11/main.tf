data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "generated_key" {
  public_key = file("../../.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "allow_ssh_test"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "Ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_test"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.centos.id
  instance_type = local.workspace["instance_type"]
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_http_https.id}"]
  tags = {
    Name = "HelloWorld"
  }
  
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_subnet" "subnet" {
  count = 16
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4,count.index)}"
  tags = {
    Name = "Subnet-${count.index + 0}"
  }
}



