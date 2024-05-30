terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "jenkins-project-backend-ahmet03"
    key = "backend-jenkins.tfstate"
    region = "us-east-1"    
  }
}

provider "aws" {
    region = "us-east-1"  
}

variable "tags" {
    default = ["postgresql", "node.js", "react"]
}

variable "user" {
    default = "eindhoven"
}

resource "aws_instance" "nodes" {
    ami = "ami-00beae93a2d981137"
    count = 3
    instance_type = "t2.micro"
    key_name = "firstkey"
    vpc_security_group_ids = [aws_security_group.sec-gr.id]
    iam_instance_profile = "jenkins-project-profile-${var.user}"
    tags = {
      Name = "ansible_${element(var.tags, count.index)}"
      stack = "ansible_project"
      environment = "development"
    }
    user_data = <<-EOF
              #! /bin/bash
              dnf update -y
              EOF
}

resource "aws_security_group" "sec.gr" {
  name = "jenkins-sec-gr-${var.user}"
  tags = {
    name = "jenkins-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    protocol    = "tcp"
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    protocol    = "tcp"
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

output "react_ip" {
  value = "http://${aws_instance.nodes[2].public_ip}"
} 

output "nodejs_private_ip" {
  value = aws_instance.nodes[1].private_ip
} 

output "postgre_private_ip" {
  value = aws_instance.nodes[0].private_ip
} 