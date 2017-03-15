variable "public_key_path" {
  default = {
    eu-west-2 = "~/.ssh/aws_london.pub"
  }
}

variable "key_name" {
  description = "AWS key based upon "
  default = {
    eu-west-2 = "aws_london2"
  }
}

variable "aws_region" {
  default     = "eu-west-2"
}

# CentOS 7 (x64)
variable "aws_amis" {
  default = {
    eu-west-2 = "ami-bb373ddf"
  }
}
