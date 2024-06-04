<!-- BEGIN_TF_DOCS -->
## Simple Linode Instance Create

### Connect to Linode using CLI

Manually create a personal access token: Prompts you for a token that you need to manually create. See [Linode API Keys and Tokens](https://www.linode.com/docs/products/tools/api/guides/manage-api-tokens/).

```bash
linode-cli configure --token
```

### Creating state  bucket

Export variables
```bash
export BUCKET_CLUSTER='us-east-1'
export BUCKET_NAME="tf-example-${BUCKET_CLUSTER}-${RANDOM}"
```
Create [Object Storage Bucket](https://www.linode.com/docs/products/storage/object-storage/guides/linode-cli/#create-a-bucket-with-the-cli) that will be used to store `tfstate` and `SSH` keys. The created bucket name must be added as secret `LINODE_BUCKET` of the repository.

```bash
linode-cli obj mb ${BUCKET_NAME} --cluster ${BUCKET_CLUSTER}
```
Create [Object Storage Access Key](https://www.linode.com/docs/products/tools/cli/guides/object-storage/#manage-access-keys) , two values ​​`access_key` and `secret_key` will be generated, these values ​​will be added to the repository secrets as `LINODE_ACCESS_KEY` and `LINODE_SECRET_KEY`.

```bash
linode-cli object-storage keys-create --label gha-${BUCKET_NAME} \
--bucket_access '[{"cluster": "'${BUCKET_CLUSTER}'", "bucket_name": "'${BUCKET_NAME}'", "permissions": "read_write" }]'
```

To create new Linode instances, simply insert the block containing the following values:

- `label`: Defines the instance label, which is used to identify it.
- `machine_type`: Defines the machine type for the instance. In this case it is set to "g6-standard-1".
- `region`: Defines the region where the instance will be created. In this case, it is set to "us-east".
- `image`: Specifies the image that will be used to create the instance. The image provided is "linode/debian12". It's important to note that official Linode images start with "linode/", while private images start with "private/".
- `networking`: Defines the network settings for the instance.
  - `private_ip`: Enables the use of a private IP for the instance.

```yml
instances:
  - label: "client-01"
    machine_type: "g6-standard-1"
    region: "us-east"
    image: "linode/debian12"
    networking:
      private_ip: true

  - label: "client-02"
    machine_type: "g6-standard-2"
    region: "us-east"
    image: "linode/debian12"
    networking:
      private_ip: true

```
<!-- END_TF_DOCS -->