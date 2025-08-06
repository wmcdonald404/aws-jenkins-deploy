# module "ec2_instance" {
#   source  = "../../modules/terraform-aws-ec2-instance/"
# 
#   ami           = "ami-01f23391a59163da9"
#   instance_type = "t2.micro"
#   # key_name    = "user1"
#   # monitoring  = true
#   name          = "jenkins"
#   subnet_id     = "subnet-0bc1b62b777cc91b8"
#   vpc_security_group_ids = ["sg-0acef48d04fdbed20"]
# 
#   tags = {
#     Environment = "${var.aws_env}"
#     MachineRole = "Jenkins Controller"
#     Terraform   = "true"
#   }
# }
