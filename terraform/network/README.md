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

### Resources

| Name | Type |
|------|------|
| [linode_vpc.test](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/vpc) | resource |
| [linode_vpc_subnet.test](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/vpc_subnet) | resource |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipv4_range"></a> [ipv4\_range](#output\_ipv4\_range) | IPv4 Address |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet ID |
<!-- END_TF_DOCS -->