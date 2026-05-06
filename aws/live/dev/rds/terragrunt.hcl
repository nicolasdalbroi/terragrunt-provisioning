include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    database_subnet_ids = {
      "us-east-1a" = "subnet-00000001"
      "us-east-1b" = "subnet-00000002"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "git::https://github.com/nicolasdalbroi/terraform-modules.git//terraform-module-rds?ref=main"
}

inputs = {
  primary_cluster_name          = "my-app-${local.env.locals.env}-primary"
  primary_cluster_instance_name = "my-app-${local.env.locals.env}-primary-instance"

  # Engine
  cluster_engine         = "aurora-postgresql"
  cluster_engine_version = "15.4"

  create_global_cluster     = false
  secondary_cluster_enabled = false

  subnet_ids = values(dependency.vpc.outputs.database_subnet_ids)

  rds_instance_class     = "db.t3.medium"
  primary_instance_count = 1

  database_username                   = "appuser"
  iam_database_authentication_enabled = false

  public_access = false

  tags = local.env.locals.common_tags
}
