terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Replace this with bucket name!
    bucket         = "djcalm-terraform-state"
    key            = "workspace/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with DynamoDB table name!
    dynamodb_table = "djcalm-terraform-locks"
    encrypt        = true
  }
}


provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "app_sg" {
  name_prefix = "microservices-app-"
  description = "Security group for microservices application"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microservices-app-sg"
  }
}

resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  security_groups       = [aws_security_group.app_sg.name]
  
  tags = {
    Name = "microservices-app-server"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    server_ip = aws_instance.app_server.public_ip
    key_path  = var.private_key_path
  })
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [aws_instance.app_server]
}

resource "null_resource" "run_ansible" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "cd ${path.module}/../ansible && ansible-playbook -i inventory.ini site.yml"
  }

  triggers = {
    server_id = aws_instance.app_server.id
  }
}