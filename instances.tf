locals {
  instances_config_path = "./values/instances"
  instance_sets         = fileset(local.instances_config_path, "*.yml")
  instances = flatten([for instance in local.instance_sets : [
    for idx, content in yamldecode(file("${local.instances_config_path}/${instance}")).instances : content
    ]
  ])
}

# Generate a random password

resource "random_password" "password" {
  for_each         = { for instance in local.instances : instance.label => instance }
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Generate a new SSH key
resource "tls_private_key" "ssh_keys" {
  for_each  = { for instance in local.instances : instance.label => instance }
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a file
resource "local_file" "private_key" {
  for_each        = { for instance in local.instances : instance.label => instance }
  content         = tls_private_key.ssh_keys[each.key].private_key_pem
  filename        = "ssh/${each.value.label}_rsa.pem"
  file_permission = "0600"
  depends_on      = [tls_private_key.ssh_keys]
}

# Create a Linode SSH key
resource "linode_sshkey" "foo" {
  for_each   = { for instance in local.instances : instance.label => instance }
  label      = each.value.label
  ssh_key    = chomp(tls_private_key.ssh_keys[each.key].public_key_openssh)
  depends_on = [tls_private_key.ssh_keys]
}

# Create a Linode instance
resource "linode_instance" "default" {
  for_each        = { for instance in local.instances : instance.label => instance }
  label           = lower(join("-", compact([each.value.label, each.value.region])))
  region          = each.value.region
  type            = each.value.machine_type
  image           = each.value.image
  root_pass       = random_password.password[each.key].result
  authorized_keys = [trimspace(tls_private_key.ssh_keys[each.key].public_key_openssh)]
  private_ip      = true

}
