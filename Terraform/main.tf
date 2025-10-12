terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "servernode" {
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-08b45c3be43b3f7ab"
  vpc_security_group_ids = [aws_security_group.maingroup.id]
  key_name               = "1"

  tags = {
    Name = "DeployVM"
  }
}

resource "aws_security_group" "maingroup" {
  name        = "main_sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = "vpc-0dcd0752cba421c53"

  ingress = [
    {
      description      = "Allow SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

output "instance_public_ip" {
  value = aws_instance.servernode.public_ip
}

