terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.30"
    }
  }
}

provider "vultr" {
}
