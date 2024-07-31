#####################################
## Virtual Machine Module - Output ##
#####################################

output "linux_server_public_ips" {
  value = {
    for key, eip in aws_eip.lb : key => eip.public_ip
  }
}

output "iscsi_server_public_ips" {
  value = { 
    for key, instance in aws_instance.iscsi-server : key => instance.public_ip 
  }
}

# output "linux_server_public_ips" {
#   value = { 
#     for key, instance in aws_instance.linux-server : key => instance.public_ip 
#   }
# }

# output "iscsi_server_public_ip" {
#   value = {
#     for key, eip in aws_eip.iscsi : key => eip.public_ip
#   }
# }

