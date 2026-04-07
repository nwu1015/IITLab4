terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

backend "s3" {
    bucket = "terraform-state-bukket-194722430189-us-east-1-an"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "lab6_sg" {
  name        = "lab6-security-group"
  description = "Allow SSH and HTTP"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0ec10929233384c7f"
  instance_type          = "t2.micro"
  key_name               = "keyforlab4"
  vpc_security_group_ids = [aws_security_group.lab6_sg.id]


  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    docker run -d --name my-app -p 80:80 nwu1015/iit-lab4:latest
    docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower --interval 30
  EOF




 tags = {
    Name        = "Lab-Terraform-Instance" 
    Environment = "Education"
  }
}

output "instance_public_ip" {
  description = "Публічна IP-адреса сервера"
  value       = aws_instance.web_server.public_ip
}