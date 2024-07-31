###################################
## Virtual Machine Module - Main ##
###################################
resource "aws_eip" "lb" {
  for_each = aws_instance.linux-server
  instance = each.value.id
}

# resource "aws_eip" "iscsi" {
#   for_each = aws_instance.iscsi-server
#   instance = each.value.id
# }

# Create EC2 Instance
resource "aws_instance" "linux-server" {
  for_each                    = var.instance_names
  ami                         = "ami-064ac61091898694e"
  instance_type               = "t3a.micro"
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.aws-linux-sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.example.key_name

  # root disk
  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${lower(var.app_name)}-${each.key}"
    Environment = var.app_environment
  }
}

// EBS Multi attach only for Master/NodeA/NodeB
resource "aws_ebs_volume" "nodes" {
  availability_zone    = "ap-south-1b"
  size                 = 30
  type                 = "io2"
  iops                 = 500
  multi_attach_enabled = true
}

resource "aws_volume_attachment" "ebs_att_linux" {
  count       = length(keys(var.instance_names))
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.nodes.id
  instance_id = aws_instance.linux-server[keys(var.instance_names)[count.index]].id
}


resource "aws_instance" "iscsi-server" {
  for_each                    = var.instance_names_iscsi
  ami                         = "ami-0763cf792771fe1bd"
  instance_type               = "t3a.micro"
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.aws-linux-sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.example.key_name

  # root disk
  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${lower(var.app_name)}-${each.key}"
    Environment = var.app_environment
  }
}

// EBS  only for Iscsi Target Server
resource "aws_ebs_volume" "iscsi_target" {
  availability_zone    = "ap-south-1b"
  size                 = 20
  type                 = "io2"
  iops                 = 500
  multi_attach_enabled = true

}

// EBS  only for Iscsi Target Server
resource "aws_volume_attachment" "ebs_att_iscsi_target" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.iscsi_target.id
  instance_id = aws_instance.iscsi-server["iscsi_target"].id
}



# resource "aws_volume_attachment" "ebs_att_iscsi_target" {
#   count       = length(keys(var.instance_names_iscsi))
#   device_name = "/dev/sdd"
#   volume_id   = aws_ebs_volume.example.id
#   instance_id = aws_instance.iscsi-server[keys(var.instance_names_iscsi)[count.index]].id
# }


resource "random_string" "random" {
  length  = 4
  special = false
}

# Define the security group for the Linux server
resource "aws_security_group" "aws-linux-sg" {
  # name        = "${lower(var.app_name)}-${random_integer.priority.result}-linux-sg"
  name        = "${lower(var.app_name)}-${random_string.random.result}-linux-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-linux-sg"
    Environment = var.app_environment
  }
}
