<!-- BEGIN_TF_DOCS -->
## Simple Linode Instance Create

**TODO:** Explicar funcionamento

```yml
instances:
  - label: "zabbix" # Set the label of the instance
    machine_type: "g6-standard-1" # [REQUIRED] Define the machine type
    region: "us-east" # [REQUIRED] Define the region of the instance
    image: "linode/debian12" # Image used to create the instance.Official Linode Images start with linode/, while your Images start with private/.
    networking:
      private_ip: true # Enable private IP
```

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
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

### Resources

| Name | Type |
|------|------|
| [linode_instance.default](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/instance) | resource |
| [linode_object_storage_key.default](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/object_storage_key) | resource |
| [linode_object_storage_object.object](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/object_storage_object) | resource |
| [linode_sshkey.foo](https://registry.terraform.io/providers/linode/linode/2.17.0/docs/resources/sshkey) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/2.5.1/docs/resources/file) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |
| [tls_private_key.ssh_keys](https://registry.terraform.io/providers/hashicorp/tls/4.0.5/docs/resources/private_key) | resource |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_label"></a> [instance\_label](#output\_instance\_label) | Instances created name |
<!-- END_TF_DOCS -->