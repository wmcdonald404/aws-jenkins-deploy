# Debian 12:    ami-0548d28d4f7ec72c5 (x86) /  ami-046a28e4666154ec2 (Arm)
# Ubuntu 24.04: ami-042b4708b1d05f512 (x86) / ami-0969826571f0530f7 (Arm)

variable "ami_id" {
  type    = string
  default = "ami-042b4708b1d05f512"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1" 
}

variable "aws_target_account_id" {
  type = string
}

variable "default_sg" {
  type = string
  default = "default"
}

variable "environment_prefix" {
  type = string
  default = "dev"
}

variable "key_pair" {
  type    = string
}

variable "role" {
  type  = string
}

variable "ssh_sg" {
  type  = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.large", "m7-flex.large", "m7i-flex.2xlarge", "c6i.xlarge", "c6i.xlarge"], var.instance_type)
    error_message = "Invalid instance type. Allowed values are t3.micro, m7-flex.large, and c6i.xlarge."
  }
}

variable "subnet_id" {
  type    = string
}

variable "vpc_id" {
  type    = string
}

variable "tags" {
  type = object(
    {
      Name                        = string
      _CostCenter                 = string
      _CostCenterDescription      = string
      _BusinessArea               = string
      _BusinessSegment            = string
      _BusinessSegmentDescription = string
      _BusinessContact            = string
      _BusinessContactEmail       = string
      _TechnicalContact           = string
      _TechnicalContactEmail      = string
      _BackupPlan                 = string
      _SupportTier                = string
      _SupportTierDescription     = string
      _ProvisioningJustification  = string
      _ProvisioningEntity         = string
      map-migrated                = string
      _Environment                = string
      _FunctionalArea             = string
      _ProvisioningEngineer       = string
      _InstanceSource             = string
      _NetworkLocation            = string
      _TerminationJustification   = string
    }  
  )
}