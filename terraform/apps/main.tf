locals {
  region       = "eu-west-2"
  ami          = "ami-0e8d228ad90af673b"
  user         = "ubuntu"
  tracker-port = 3000
  viewer-port  = 8280
}

provider "aws" {
  region = local.region
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
    from_port   = local.tracker-port
    to_port     = local.tracker-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.viewer-port
    to_port     = local.viewer-port
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
  filename        = "apps/keypair.pem"
  file_permission = "0600"
  content         = tls_private_key.ec2_key.private_key_pem
}

resource "aws_instance" "snowplow-demo" {
  ami                    = local.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.snowplow-demo-sg.id]
  key_name               = aws_key_pair.ec2_key.key_name

  tags = {
    Name = "snowplow-demo-instance"
  }

  connection {
    type        = "ssh"
    user        = local.user
    private_key = tls_private_key.ec2_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "./apps/aws-zip.sh"
  }

  provisioner "file" {
    source      = "apps/snowplow-demo.zip"
    destination = "/home/${local.user}/snowplow-demo.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt install -y unzip tree",
      "unzip -q /home/${local.user}/snowplow-demo.zip -d /home/${local.user}/snowplow-demo",
      "bash /home/${local.user}/snowplow-demo/terraform/apps/docker-install.sh",
      "rm -f /home/${local.user}/snowplow-demo.zip",
      "rm -rf /home/${local.user}/snowplow-demo/terraform"
    ]
  }
}

resource "local_file" "ssh_cmd" {
  filename        = "apps/ssh.sh"
  file_permission = "0775"
  content         = <<-EOF
  #!/usr/bin/env bash
  set -eou pipefail
  cd $(dirname $0)

  ssh -i keypair.pem ${local.user}@${aws_instance.snowplow-demo.public_dns}
  EOF
}

output "public_dns" {
  value = aws_instance.snowplow-demo.public_dns
}
