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
    }
  }
}


#data "aws_vpc" "my_vpc" {
#  tags = {
#    Terraform = "true"
#    Environment = "dev"
#  }
#}

data "aws_vpc" "my_vpc" {
  default = "true"
}

# Exemplo 1: Construindo um security group para liberar ingresso na porta 80 de qualquer origem:

resource "aws_security_group" "web_server_sg" {

  name        = "allow_web_server_access"
  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = data.aws_vpc.my_vpc.id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web_server_access"
    Terraform = "true"
    Environment = "dev"
    Tier = "FE"
  }
}

# Exemplo 2: Construindo um security group com dois tipos de regras:
# 1 Reggra de acesso na mesma porta baseada em três ranges ficticios de backends;
# 2 Regra baseada no acesso a porta 3306 com origem no grupo criado anteriomente;
  
module "mysql_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/mysql"

  name        = "computed-mysql-sg"
  description = "Security group with MySQL/Aurora port open for HTTP security group created above (computed)"
  vpc_id      = data.aws_vpc.my_vpc.id

  ingress_cidr_blocks = local.private_subnets

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = aws_security_group.web_server_sg.id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
}
