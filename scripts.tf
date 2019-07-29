provider "aws" {
  endpoints {
    ec2 = "https://api.cloud.croc.ru"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  access_key = ""
  secret_key = ""
  region     = "croc"
}

variable "template" {
  default = "cmi-B3B959C5"
}

variable "key_path" {
  default = "/root/.ssh/authorized_keys"
}

resource "aws_vpc" "deploy" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.deploy.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "ru-msk-vol51"
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

    ingress {
    from_port   = 3389
    to_port     = 3389
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

resource "aws_instance" "test" {
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
  private_ip        = "10.10.1.10"
  count             = 1
  provisioner "local-exec" {
    command = "source /root/api.sh; c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.test.id} Description.Value test"
  }

}