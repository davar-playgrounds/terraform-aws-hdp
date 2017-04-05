
variable "aws_region" {
  description = "default AWS location"
  default     = "eu-west-2"
}

variable "public_key_path" {
  description = "Location of the ssh pub key"
  default     = {
    eu-west-2 = "~/.ssh/aws_london.pub"
  }
}

variable "key_name" {
  description = "AWS key name "

  default     = {
    eu-west-2 = "aws_london2"
  }
}

# CentOS 7 (x64)
variable "aws_amis" {
  description = "AMI name based upon region"
  default     = {
    eu-west-2 = "ami-bb373ddf"
  }
}

variable "user" {
  description = "user to login"
  default     = "centos"
}

variable "master_nodes" {
  description = "number of master nodes"
  default     = "1"
}

variable "worker_nodes" {
  description = "number of worker nodes"
  default     = "3"
}
