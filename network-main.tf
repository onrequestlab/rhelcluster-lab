# ##########################################
# ## Network Single AZ Public Only - Main ##
# ##########################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  id = "subnet-0b68f0de6853f3349"
}
  #   filter {
  #   name   = "availability-zone-1b"
  #   values = ["ap-south-1b"]
  # }

