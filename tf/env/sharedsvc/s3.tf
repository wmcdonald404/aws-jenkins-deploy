# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest

module "s3_bucket" {
  
  source = "../../modules/terraform-aws-s3-bucket/"

  acl    = "private"
  bucket = "${var.aws_account}-${var.aws_env}-s3-state-bucket"
  control_object_ownership = true
  force_destroy            = true
  object_ownership         = "ObjectWriter"
  versioning = {
    enabled  = true
  }

  tags = {
    Terraform   = "true"
    Environment = "${var.aws_env}"
  }
}
