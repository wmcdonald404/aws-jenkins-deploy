variable "aws_account" {
  type = string
}

variable "aws_env" {
  type = string
  default = "development"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1" 
}
