<!-- BEGIN_TF_DOCS -->
## Simple Linode Instance Create

**TODO:** Explicar funcionamento

- Criar um bucket que irá armazenar os terraform state e as private keys.
- Criar as chaves para acesso ao bucket

```yml
instances:
  - label: "zabbix" # Set the label of the instance
    machine_type: "g6-standard-1" # [REQUIRED] Define the machine type
    region: "us-east" # [REQUIRED] Define the region of the instance
    image: "linode/debian12" # Image used to create the instance.Official Linode Images start with linode/, while your Images start with private/.
    networking:
      private_ip: true # Enable private IP
```
<!-- END_TF_DOCS -->