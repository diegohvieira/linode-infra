data "linode_domain" "default" {
  domain = local.configs.domain
}
