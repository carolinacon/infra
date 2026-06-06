terraform {
  backend "s3" {
    bucket = "ccon-tfstate"
    key    = "global/cloud_firewalls/vultr/terraform.tfstate"
    region = "us-west-2"

    use_lockfile = true
    encrypt      = true
  }
}