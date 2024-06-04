locals {
  storages_config_path = "../../values/storage"
  storage_sets         = fileset(local.storages_config_path, "*.yml")
  storages = flatten([for storage in local.storage_sets : [
    for idx, content in yamldecode(file("${local.storages_config_path}/${storage}")).storages : content
    ]
  ])
}

resource "random_integer" "sufix" {
  for_each = { for storage in local.storages : each.value.label => storage }
  min = 1
  max = 9999
  keepers = {
    label = each.value.label
  }
}

resource "linode_object_storage_bucket" "mybucket" {
  for_each = { for storage in local.storages : each.value.label => storage }
  access_key = can(linode_object_storage_key.default[each.key].access_key) ? linode_object_storage_key.default[each.key].access_key : null
  secret_key = can(linode_object_storage_key.default[each.key].secret_key) ? linode_object_storage_key.default[each.key].secret_key : null
  cluster = each.value.region
  label   = lower(join("-", compact([each.value.label, each.value.region, random_integer.sufix[each.key].result])))
  versioning = can(each.value.versioning) && can(linode_object_storage_key.default[each.key].access_key) ? each.value.versioning : null
}

resource "linode_object_storage_key" "default" {
  for_each = { for storage in local.storages : each.value.label => storage }
  label = lower(join("-", compact([each.value.label, each.value.region, "key"])))
  bucket_access {
    bucket_name = linode_object_storage_bucket.mybucket[each.key].label
    cluster     = linode_object_storage_bucket.mybucket[each.key].cluster
    permissions = "read_write"
  }
}
