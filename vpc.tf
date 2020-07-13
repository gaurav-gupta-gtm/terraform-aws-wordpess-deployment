provider "aws" {
  region     = "ap-south-1"
  profile    = "terrauser"
}

resource "tls_private_key" "key_form" {
  algorithm = "RSA"
}

resource "aws_key_pair" "task_key" {
  key_name   = "task_key"
  public_key = "${tls_private_key.key_form.public_key_openssh}"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.5.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "alpha-1a" {
  vpc_id            = "${aws_vpc.myvpc.id}"
  availability_zone = "ap-south-1a"
  cidr_block        = "10.5.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-1a"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "main-1a"
  }
}
resource "aws_route_table" "rtable" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "main-1a"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.alpha-1a.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_security_group" "allow_http_wordpress" {
  name        = "allow_http_wordpress"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    description = "Http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgroup"
  }
}

resource "aws_subnet" "alpha-1b" {
  vpc_id            = "${aws_vpc.myvpc.id}"
  availability_zone = "ap-south-1b"
  cidr_block        = "10.5.2.0/24"
  tags = {
    Name = "main-1b"
  }
}
resource "aws_security_group" "mysql-sg" {
  name        = "for-mysql"
  description = "MYSQL-setup"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    description = "MYSQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgroup"
  }
}