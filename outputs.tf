output "root_password" {
  value     = { for k, v in random_password.password : k => base64encode(v.result) }
  sensitive = true
}
