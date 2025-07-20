# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

module "vpc" {
  source = "../../../modules/terraform-aws-vpc/"


  name = "production-vpc"
  cidr = "10.4.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.4.1.0/24", "10.4.2.0/24", "10.4.3.0/24"]
  public_subnets  = ["10.4.101.0/24", "10.4.102.0/24", "10.4.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  # create_egress_only_igw = true

  tags = {
    Terraform = "true"
    Environment = "production"
  }
}