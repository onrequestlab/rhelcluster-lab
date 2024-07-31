#####################################
## AWS Provider Module - Variables ##
#####################################

# AWS connection & authentication

variable "aws_region" {
  type = string
  description = "AWS region"
}

variable "instance_names" {
  default = {
    "master" = "1"
    "nodea"  = "2"
    "nodeb"  = "3"
    # "nodec"  = "4"
  }
}

variable "instance_names_iscsi" {
  default = {
    "iscsi_target" = "1"
    "iscsi_client"  = "2"
  }
}
