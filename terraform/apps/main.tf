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
    from_port   = local.kafka-ui-port
    to_port     = local.kafka-ui-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.viewer-port
    to_port     = local.viewer-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.backend-port
    to_port     = local.backend-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.collector-port
    to_port     = local.collector-port
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
  filename        = "${path.module}/keypair.pem"
  file_permission = "0600"
  content         = tls_private_key.ec2_key.private_key_pem
}

resource "aws_dynamodb_table" "video_events" {
  name           = var.table_name
  hash_key       = "viewer_id"
  range_key      = "collector_tstamp"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "viewer_id"
    type = "S"
  }
  attribute {
    name = "collector_tstamp"
    type = "S"
  }
}

resource "aws_instance" "snowplow-demo" {
  ami                    = local.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.snowplow-demo-sg.id]
  key_name               = aws_key_pair.ec2_key.key_name

  root_block_device {
    volume_size = 12
  }

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
    command = "zip_name=${local.zip-name} ./${path.module}/aws-zip.sh"
  }

  provisioner "file" {
    source      = "${path.module}/${local.zip-name}"
    destination = "/home/${local.user}/${local.zip-name}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Updating apt ...'",
      "sudo apt update",

      "echo 'Installing unzip ...'",
      "sudo apt install -y unzip",

      "echo 'Extracting ${local.remote-zip-file} to ${local.remote-app-dir} ...'",
      "unzip -q ${local.remote-zip-file} -d ${local.remote-app-dir}",

      "echo 'Running ${local.remote-install-sh} ...'",
      "chmod +x ${local.remote-install-sh}",
      "${local.remote-install-sh} '${aws_instance.snowplow-demo.public_dns}'",
    ]
  }
}

resource "local_file" "ssh_cmd" {
  filename        = "${path.module}/ssh.sh"
  file_permission = "0775"
  content         = <<-EOF
  #!/usr/bin/env bash
  set -eou pipefail
  cd $(dirname $0)

  ssh -i keypair.pem ${local.user}@${aws_instance.snowplow-demo.public_dns}
  EOF
}
