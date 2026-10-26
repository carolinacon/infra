terraform {
  backend "s3" {
    bucket       = "ccon-tfstate"
    key          = "development/desktops/livestream/terraform.tfstate"
    region       = "us-west-2"

    use_lockfile = true
    encrypt      = true
  }
}