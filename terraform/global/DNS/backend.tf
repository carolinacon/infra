terraform {
  backend "s3" {
    bucket = "ccon-tfstate"
    key    = "global/DNS/terraform.tfstate"
    region = "us-west-2"

    use_lockfile = true
    encrypt      = true
  }
}