# Reading .yml files from the config directory
locals {
  config_path = "../../config"
  configs     = yamldecode(file("${local.config_path}/default.yml")).defaults
}

# Reading .yml files from the values/instances directory
locals {
  instances_config_path = "../../values/instances"
  instance_sets         = fileset(local.instances_config_path, "*.yml")
  instances = flatten([for instance in local.instance_sets : [
    for idx, content in yamldecode(file("${local.instances_config_path}/${instance}")).instances : content
    ]
  ])
}

# Create a Linode Object Storage keys
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/object_storage_key
resource "linode_object_storage_key" "default" {
  label = "gha-linode-infra"
  bucket_access {
    bucket_name = local.configs.bucket_name
    cluster     = local.configs.bucket_region
    permissions = "read_write"
  }
}

# TODO: Save random password to a file or secret manager
# Generate a random password
# Reference: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
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

# TODO: Save the public key in secret manager
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
  bucket     = local.configs.bucket_name
  cluster    = local.configs.bucket_region
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
  region          = can(each.value.region) ? each.value.region : local.configs.region
  type            = can(each.value.machine_type) ? each.value.machine_type : local.configs.machine_type
  image           = can(each.value.image) ? each.value.image : local.configs.image
  root_pass       = random_password.password[each.key].result
  authorized_keys = [trimspace(tls_private_key.ssh_keys[each.key].public_key_openssh)]
  private_ip      = can(each.value.networking.private_ip) && each.value.networking.private_ip == true ? each.value.networking.private_ip : null

  interface {
    purpose = "public"
  }

  dynamic "interface" {
    for_each = can(each.value.networking.vpc.subnet_id) ? [each.value.networking.vpc.subnet_id] : []
    content {
      purpose   = "vpc"
      subnet_id = try(each.value.networking.vpc.subnet_id, local.configs.networking.subnet_id)
      dynamic "ipv4" {
        for_each = can(each.value.networking.vpc.ipv4) ? [1] : []
        content {
          vpc = try(each.value.networking.vpc.ipv4, [])
        }
      }
    }
  }

  depends_on = [linode_object_storage_object.object, linode_sshkey.foo]
}

# Register a Linode Domain
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/domain
resource "linode_domain_record" "instance_domain" {
  for_each    = { for instance in local.instances : instance.label => instance }
  domain_id   = data.linode_domain.default.id
  name        = can(each.value.record_name) ? lower(each.value.record_name) : lower(each.value.label)
  record_type = can(each.value.record_type) ? each.value.record_type : "A"
  target      = linode_instance.default[each.key].ip_address
  depends_on  = [linode_instance.default]
}
