locals {
  # Ids for multiple sets of EC2 instances, merged together
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

data "aws_vpc" "my-vpc" {
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = data.aws_vpc.my-vpc

  ingress_cidr_blocks = local.public_subnets
}

module "private_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "private-service"
  description = "Security group for backend services with custom ports open only for internal networks"
  vpc_id      = data.aws_vpc.my-vpc

  ingress_cidr_blocks      = local.private_subnets
  ingress_rules            = ["postgresql-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks =  local.private_subnets
    }
  ]
}