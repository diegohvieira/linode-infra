output "instance_label" {
  description = "Instances created name"
  value = {
    for k, v in linode_instance.default : k => v.label
  }
}
