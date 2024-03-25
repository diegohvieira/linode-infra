# Get autorized use to create linode instance
data "linode_profile" "my_profile" {}

# Configure Terraform to use the Linode Provider
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.17.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

# Configure the Linode Provider
## TODO: Replace the token with your own Linode Personal Access Token
#provider "linode" {
#  token = "384e9e6e77026fee7a9d826c4abf2be716fa6a265ef40063f7cd683987c943c5"
#}
#
