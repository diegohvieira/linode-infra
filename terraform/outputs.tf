output "instance_label" {
  description = "Instances created name"
  value = {
    for k, v in linode_instance.default : k => v.label
  }
}

output "ip_address" {
  description = "Instances created IP address"
  value = {
    for k, v in linode_instance.default : k => v.ip_address
  }
}
