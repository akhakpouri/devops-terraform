terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "value"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "sample" {
  ami           = "ami-00beae93a2d981137"
  instance_type = "t2.micro"
}
