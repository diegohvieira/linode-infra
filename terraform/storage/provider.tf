# Configure Terraform to use the Linode Provider
terraform {
  required_version = ">=1.7.0"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.17.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}
