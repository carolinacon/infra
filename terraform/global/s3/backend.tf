terraform {
  backend "s3" {
    bucket       = "ccon-tfstate"
    key          = "global/s3/terraform.tfstate"
    region       = "us-west-2"

    use_lockfile = true
    encrypt      = true
  }
}