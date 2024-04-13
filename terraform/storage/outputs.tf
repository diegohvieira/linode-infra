output "subnet_id" {
  description = "Subnet ID"
  value = {
    for k, v in linode_vpc_subnet.test : k => v.label
  }
}

output "ipv4_range" {
  description = "IPv4 Address"
  value = {
    for k, v in linode_vpc_subnet.test : k => v.ipv4
  }
}
