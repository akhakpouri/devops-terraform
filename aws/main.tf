terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"
  tags = {
    Name = var.instance_name
  }
}
