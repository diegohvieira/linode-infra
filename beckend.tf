terraform {
  backend "s3" {
    bucket         = "terraform-us-east-1-0423"
    use_path_style = true
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    endpoints = {
      s3 = "https://us-east-1.linodeobjects.com"
    }
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    access_key                  = "D8X9WFP5YUGL432GEMNE"
    secret_key                  = "CngeGOLhZR9P8eCxHhtamq9dKVLcnFbHU5ToS8PV"
    #workspace_key_prefix        = ""
  }
}


#terraform {
#  backend "s3" {
#    skip_credentials_validation = true
#    skip_requesting_account_id  = true
#    skip_metadata_api_check     = true
#    skip_region_validation      = true
#    #skip_s3_checksum            = true
#    use_path_style = true
#    endpoints = {
#      s3 = "https://us-east-1.linodeobjects.com"
#    }
#    bucket = "terraform-us-east-1-0423"
#    key    = "infra/terraform.tfstate"
#    region = "us-east-1"
#    #access_key = "D8X9WFP5YUGL432GEMNE"
#    #secret_key = "CngeGOLhZR9P8eCxHhtamq9dKVLcnFbHU5ToS8PV"
#  }
#}
#
