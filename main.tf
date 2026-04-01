terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "server_sg" {
  source      = "./modules/security_group"
  name        = "server_sg"
  description = "Security group for EC2 instances"

  ingress = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["0.0.0.0/0"] },
  ]

  egress = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] },
  ]

  tags = {
    Name = "server_sg"
  }
}

locals {
  server_names = ["server1", "server2"]
}

module "servers" {
  source                 = "./modules/instance"
  for_each               = toset(local.server_names)
  name                   = each.key
  ami                    = "ami-0cd59ecaf368e5ccf"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.server_sg.id]
  tags = {
    environment = "dev"
  }
}
