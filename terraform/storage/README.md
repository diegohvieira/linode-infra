<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.7.0 |
| <a name="requirement_linode"></a> [linode](#requirement\_linode) | 2.17.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.5 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_linode"></a> [linode](#provider\_linode) | 2.17.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

### Resources

| Name | Type |
|------|------|
| [linode_object_storage_bucket.mybucket](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/object_storage_bucket) | resource |
| [linode_object_storage_key.default](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/object_storage_key) | resource |
| [random_integer.sufix](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/integer) | resource |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipv4_range"></a> [ipv4\_range](#output\_ipv4\_range) | IPv4 Address |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet ID |
<!-- END_TF_DOCS -->