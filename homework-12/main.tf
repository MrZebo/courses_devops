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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
}

resource "aws_key_pair" "generated_key" {
  public_key = file("../../.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow-ssh" {
  vpc_id      = aws_vpc.vpc.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.workspace["instance_type"]
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  tags = {
    Name = "Public instance"
  }

}

resource "aws_instance" "web" {
  ami           = data.aws_ami.centos.id
  instance_type = local.workspace["instance_type"]
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  tags = {
    Name = "Private instance"
  }

}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Not default VPC"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.16/28"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "public-rout-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public-rout-table-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rout-table.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private-rout-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
}

resource "aws_route_table_association" "private-rout-table-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rout-table.id
}
