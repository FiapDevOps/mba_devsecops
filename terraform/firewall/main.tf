# https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/http/main.tf


# Configurando o cloud provider
provider "aws" {
  region = "us-east-1"
}

locals {
  # Ids for multiple sets of EC2 instances, merged together
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_vpc" "my_vpc" {
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = data.aws_vpc.my_vpc.id

  tags = {
    Terraform = "true"
    Environment = "dev"
    Tier = "FE"
  }

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "mysql_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/mysql"

  name        = "computed-mysql-sg"
  description = "Security group with MySQL/Aurora port open for HTTP security group created above (computed)"
  vpc_id      = data.aws_vpc.my_vpc.id

  tags = {
    Terraform = "true"
    Environment = "dev"
    Tier = "BE"
  }

  ingress_cidr_blocks = local.private_subnets

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.web_server_sg.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
}