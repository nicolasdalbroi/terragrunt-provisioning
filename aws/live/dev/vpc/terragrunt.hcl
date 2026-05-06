include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "git::https://github.com/nicolasdalbroi/terraform-modules.git//terraform-module-vpc?ref=main"  
}

inputs = {
  name   = "my-app-${local.env.locals.env}"
  region = local.env.locals.region

  vpc_cidr_block = "10.1.0.0/16"  # Use a different CIDR per env to avoid overlap

  public_subnets = {
    "us-east-1a" = "10.1.1.0/24"
    "us-east-1b" = "10.1.2.0/24"
  }

  private_subnets = {
    "us-east-1a" = "10.1.10.0/24"
    "us-east-1b" = "10.1.11.0/24"
  }

  database_subnets = {
    "us-east-1a" = "10.1.20.0/24"
    "us-east-1b" = "10.1.21.0/24"
  }

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = true
  nat_gateway_azs = {
    "us-east-1a" = true
    "us-east-1b" = true
  }

  create_public_nacl  = false
  create_private_nacl = false

  tags = local.env.locals.common_tags
}
