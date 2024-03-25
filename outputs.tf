#output "root_password" {
#  value     = { for k, v in random_password.password : k => base64encode(v.result) }
#  sensitive = true
#}

output "instance_label" {
  description = "Instances created name"
  value = {
    for k, v in linode_instance.default : k => v.label
  }
}
