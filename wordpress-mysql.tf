resource "aws_instance" "wordpress" {
  ami           = "ami-0979674e4a8c6ea0c"
  instance_type = "t2.micro"
  key_name      = "task_key"
  availability_zone = "ap-south-1a"
  subnet_id     = "${aws_subnet.alpha-1a.id}"
  security_groups = [ "${aws_security_group.allow_http_wordpress.id}" ]
  tags = {
    Name = "Wordpress"
  }
}

resource "aws_instance" "mysql" {
  ami           = "ami-76166b19"
  instance_type = "t2.micro"
  key_name      = "task_key"
  availability_zone = "ap-south-1b"
  subnet_id     = "${aws_subnet.alpha-1b.id}"
  security_groups = [ "${aws_security_group.mysql-sg.id}" ]
  tags = {
    Name = "MYSQL"
  }
}

resource "null_resource" "save_key_pair"  {
	provisioner "local-exec" {
	    command = "echo  '${tls_private_key.key_form.private_key_pem}' > key.pem"
  	}
}


output "key-pair" {
  value = tls_private_key.key_form.private_key_pem
}
