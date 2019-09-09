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

variable "admin_password" {
description = "Windows Administrator password to login as"
}

resource "aws_vpc" "deploy" {
  cidr_block = "100.7.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.deploy.id}"
  cidr_block = "100.7.1.0/28"
  availability_zone = "ru-msk-vol51"
}

resource "aws_security_group" "deploy" {
  name        = "deploy"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.deploy.id}"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
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
data "template_file" "init" {
   template = <<EOF
   <script>
     winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm/config @{MaxEnvelopeSizekb="8000kb"}
   </script>
   <powershell>
     netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
     $admin = [ADSI]("WinNT://./administrator, user")
     $admin.SetPassword(“${var.admin_password}”)
   </powershell>
EOF
   vars {
     admin_password = "${var.admin_password}"
   }
}
resource "aws_instance" "terraform-test" {
  ami               = "cmi-48739504"
  instance_type     = "c1.large"
  availability_zone = "ru-msk-vol51"
  subnet_id         = "${aws_subnet.subnet.id}"
  depends_on        = ["aws_subnet.subnet"]
  monitoring        = true
  source_dest_check = false
  associate_public_ip_address = true
  user_data       = "${data.template_file.init.rendered}"
  security_groups   = ["${aws_security_group.deploy.id}"]
  count             = 1


provisioner "local-exec" {
   command = "sleep 60"
}
provisioner "remote-exec" {
   connection = {
     type       = "winrm"
     user       = "Administrator"
     password   = "${var.admin_password}"
     agent       = "false"
   }
   inline = [
     "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
   ]
   }
}
