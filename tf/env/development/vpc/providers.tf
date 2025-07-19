# See: https://stackoverflow.com/a/66141608 for vars in backend definition.

terraform {
  # 1.10 is the minimum version for native s3 statefile locking
  required_version = "~> 1.10"

#   backend "s3" {
#     bucket       = ""
#     encrypt      = true
#     key          = ""
#     region       = ""
#     # This enables native S3 state locking
#     use_lockfile = true
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.4.0"
    }
  }
}

# https://search.opentofu.org/provider/hashicorp/aws/latest
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_target_account_id]
}