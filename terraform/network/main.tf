# Reading .yml files from the config directory
locals {
  config_path = "../../config"
  configs     = yamldecode(file("${local.config_path}/default.yml")).defaults
}

locals {
  network_config_path = "../../values/network"
  network_sets        = fileset(local.network_config_path, "*.yml")
  network = flatten([for network in local.network_sets : [
    for idx, content in yamldecode(file("${local.network_config_path}/${network}")).vpcs : content
    ]
  ])
  subnets = flatten([
    for network in local.network : [
      for subnet in network.subnets : merge({
        vpc_label  = network.label
        vpc_region = network.region
      }, subnet)
    ]
  ])
}

# Create a Linode VPC.
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/vpc
resource "linode_vpc" "test" {
  for_each    = { for network in local.network : network.label => network }
  label       = lower(join("-", compact([each.value.label, each.value.region, "vpc"])))
  region      = can(each.value.region) ? each.value.region : local.configs.region
  description = can(each.value.description) ? each.value.description : null
}

# Create a Linode VPC subnet.
# Reference: https://registry.terraform.io/providers/linode/linode/latest/docs/resources/vpc_subnet
resource "linode_vpc_subnet" "test" {
  for_each = { for subnet in local.subnets : "${subnet.vpc_label}-${subnet.label}" => subnet }
  vpc_id   = linode_vpc.test[each.value.vpc_label].id
  label    = lower(join("-", compact([each.value.vpc_label, each.value.vpc_region, each.value.label, "subnet"])))
  ipv4     = each.value.range
}
