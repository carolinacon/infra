terraform {
  backend "s3" {
    bucket       = "ccon-tfstate"
    key          = "global/r2/terraform.tfstate"
    region       = "us-west-2"

    use_lockfile = true
    encrypt      = true
  }
}