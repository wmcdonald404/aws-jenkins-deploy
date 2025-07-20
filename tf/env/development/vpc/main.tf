# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

module "vpc" {
  source = "../../../modules/terraform-aws-vpc/"

  name = "development-vpc"
  cidr = "10.2.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  public_subnets  = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  # create_egress_only_igw = true

  tags = {
    Terraform = "true"
    Environment = "development"
  }
}