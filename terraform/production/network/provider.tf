terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.30"
    }
  }
}

provider "vultr" {
}
