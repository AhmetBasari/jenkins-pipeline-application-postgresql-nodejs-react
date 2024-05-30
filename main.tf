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
      Name = ""
      stack = ""
    }
  
}