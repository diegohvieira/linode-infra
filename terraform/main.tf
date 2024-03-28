# Reading .yml files from the values/instances directory
locals {
  instances_config_path = "../values/instances"
  instance_sets         = fileset(local.instances_config_path, "*.yml")
  instances = flatten([for instance in local.instance_sets : [
    for idx, content in yamldecode(file("${local.instances_config_path}/${instance}")).instances : content
    ]
  ])
  private_keys_bucket_name   = "terraform-us-east-1-0423"
  private_keys_bucket_region = "us-east-1"
}

# Create a Linode Object Storage keys
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/object_storage_key
resource "linode_object_storage_key" "default" {
  label = "gha-linode-infra"
  bucket_access {
    bucket_name = local.private_keys_bucket_name
    cluster     = local.private_keys_bucket_region
    permissions = "read_write"
  }
}

# Generate a random password
#Reference: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "password" {
  for_each         = { for instance in local.instances : instance.label => instance }
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Generate a new SSH key
# Reference: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "ssh_keys" {
  for_each  = { for instance in local.instances : instance.label => instance }
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a file
# Reference: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "private_key" {
  for_each        = { for instance in local.instances : instance.label => instance }
  content         = tls_private_key.ssh_keys[each.key].private_key_pem
  filename        = "ssh/${each.value.label}_rsa.pem"
  file_permission = "0600"
  depends_on      = [tls_private_key.ssh_keys]
}

# Upload the private key to Linode Object Storage
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/object_storage_object
resource "linode_object_storage_object" "object" {
  for_each   = { for instance in local.instances : instance.label => instance }
  bucket     = local.private_keys_bucket_name
  cluster    = local.private_keys_bucket_region
  key        = "ssh/${each.value.label}_rsa.pem"
  secret_key = linode_object_storage_key.default.secret_key
  access_key = linode_object_storage_key.default.access_key
  source     = pathexpand("ssh/${each.value.label}_rsa.pem")
  depends_on = [linode_object_storage_key.default]
}


# Adding a Linode SSH key to the Linode account
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/sshkey
resource "linode_sshkey" "foo" {
  for_each   = { for instance in local.instances : instance.label => instance }
  label      = join("_", [each.value.label, "key"])
  ssh_key    = chomp(tls_private_key.ssh_keys[each.key].public_key_openssh)
  depends_on = [tls_private_key.ssh_keys]
}

# Create a Linode instance
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/instance
resource "linode_instance" "default" {
  for_each        = { for instance in local.instances : instance.label => instance }
  label           = lower(join("-", compact([each.value.label, each.value.region])))
  region          = each.value.region
  type            = each.value.machine_type
  image           = each.value.image
  root_pass       = random_password.password[each.key].result
  authorized_keys = [trimspace(tls_private_key.ssh_keys[each.key].public_key_openssh)]
  private_ip      = can(each.value.private_ip) ? each.value.private_ip : null
}

