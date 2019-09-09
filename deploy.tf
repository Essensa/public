provider "aws" {
  endpoints {
    ec2 = "https://api.cloud.croc.ru"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = "#"
  secret_key = "#"
  region     = "croc"
}

variable "key_path" {
  default = "/root/.ssh/authorized_keys"
}

resource "aws_vpc" "deploy" {
  cidr_block = "10.7.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.deploy.id}"
  cidr_block = "10.7.1.0/28"
}

resource "aws_security_group" "deploy" {
  name        = "deploy"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.deploy.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "monitoring" {
  ami               = "cmi-B3B959C5"
  instance_type     = "m1.2small"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = true
  security_groups   = ["${aws_security_group.deploy.id}"]
  key_name          = "CloudTest"
  private_ip        = "10.7.1.4"
  count             = 1
provisioner "local-exec" {
    command = "c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.monitoring.id} Description.Value monitoring"
} 
}
resource "aws_instance" "web-first" {
  ami               = "cmi-B3B959C5"
  instance_type     = "m1.2small"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = false
  security_groups   = ["${aws_security_group.deploy.id}"]
  key_name          = "CloudTest"
  private_ip        = "10.7.1.5"
  count             = 1
provisioner "local-exec" {    
    command = "c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.web-first.id} Description.Value web-first"
}
}

resource "aws_instance" "web-second" {
  ami               = "cmi-B3B959C5"
  instance_type     = "m1.2small"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = false
  security_groups   = ["${aws_security_group.deploy.id}"]
  key_name          = "CloudTest"
  private_ip        = "10.7.1.6"
  count             = 1
provisioner "local-exec" {    
    command = "c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.web-second.id} Description.Value web-second"
}
}

resource "aws_instance" "backend" {
  ami               = "cmi-B3B959C5"
  instance_type     = "m1.2small"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = false
  security_groups   = ["${aws_security_group.deploy.id}"]
  key_name          = "CloudTest"
  private_ip        = "10.7.1.7"
  count             = 1
provisioner "local-exec" {    
    command = "c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.backend.id} Description.Value backend"
}
}

resource "aws_instance" "database" {
  ami               = "cmi-B3B959C5"
  instance_type     = "m1.2small"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = false
  security_groups   = ["${aws_security_group.deploy.id}"]
  key_name          = "CloudTest"
  private_ip        = "10.7.1.8"
  count             = 1

provisioner "local-exec" {    
    command = "c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.database.id} Description.Value database"
}
}

resource "aws_instance" "api" {
  ami               = "cmi-B3B959C5"
  instance_type     = "m1.2small"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = true
  security_groups   = ["${aws_security_group.deploy.id}"]
  key_name          = "CloudTest"
  private_ip        = "10.7.1.9"
  count             = 1
provisioner "local-exec" {
    command = "source /root/api.sh"
  }
provisioner "local-exec" {    
    command = "c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.api.id} Description.Value api"
  }
}
