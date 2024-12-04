provider "aws" {
  region = "eu-west-2"
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_security_group" "snowplow-demo-sg" {
  name   = "sample-sg"
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8280
    to_port     = 8280
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

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "privatekeypair"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "keypair.pem"
  file_permission = "0600"
  content  = tls_private_key.ec2_key.private_key_pem
}

resource "aws_instance" "snowplow-demo" {
  ami           = "ami-0e8d228ad90af673b"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.snowplow-demo-sg.id]
  key_name      = aws_key_pair.ec2_key.key_name

  tags = {
    Name = "snowplow-demo-instance"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = tls_private_key.ec2_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "local-exec" {
    working_dir = ".."
    command = "./aws-zip.sh"
  }

  provisioner "file" {
    source      = "../snowplow-demo.zip"
    destination = "/home/${var.ssh_user}/snowplow-demo.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt install -y unzip tree",
      "unzip /home/${var.ssh_user}/snowplow-demo.zip -d /home/${var.ssh_user}/snowplow-demo",
      "/home/${var.ssh_user}/snowplow-demo/docker-install.sh",
      "rm -f /home/${var.ssh_user}/snowplow-demo.zip",
      "rm -f /home/${var.ssh_user}/snowplow-demo/docker-install.sh"
    ]
  }
}

output "ssh-command" {
  value = "ssh -i keypair.pem ${var.ssh_user}@${aws_instance.snowplow-demo.public_dns}"
}

output "public_ip" {
  value = aws_instance.snowplow-demo.public_ip
}
