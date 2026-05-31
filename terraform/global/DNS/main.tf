terraform {
  required_version = ">= 1.12.2"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.19"
    }
  }
}

###############################################################################
# Variables
###############################################################################

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

# variable "ctfd_subdomain" {
#   description = "Subdomain for ctfd app"
#   type        = string
# }

variable "pangolin_subdomain" {
  description = "Subdomain for pangolin app"
  type        = string
}

variable "matrix_ip" {
  description = "IP address for matrix app"
  type        = string
}

locals {
  tags = [
    "production",
    "terraform",
  ]
  terraform_prefix = "TF:"
  proxy_default    = true
  # this means auto: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record#ttl-1
  ttl_default = 1
}

###############################################################################
# Provider
###############################################################################

provider "cloudflare" {}

###############################################################################
# Provider: Data Sources
###############################################################################

data "cloudflare_zones" "main_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "carolinacon.org"
}

data "terraform_remote_state" "pangolin" {
  backend = "s3"
  config = {
    bucket       = "ccon-tfstate"
    key          = "production/network/terraform.tfstate"
    region       = "us-west-2"
  }
}

###############################################################################
# Provider: Resources created
###############################################################################

resource "cloudflare_dns_record" "apex" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name = "@"
  # (notice in web-ui): CNAME records normally can not be on the zone apex. We use CNAME flattening to make it possible. Learn more.
  # https://developers.cloudflare.com/dns/additional-options/cname-flattening/
  type    = "CNAME"
  content = "carolinacon.github.io"
  ttl     = local.ttl_default
  # https://community.cloudflare.com/t/cloudflare-api-issue-with-updating-adding-dns-a-records-exceeding-tag-quota-communitytip-error-9300/537091
  # tags = local.tags
  comment = "${local.terraform_prefix} main website cname to GH pages for website repo: https://github.com/carolinacon/CC-Website/"

  proxied = local.proxy_default
}

resource "cloudflare_dns_record" "www" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = "www"
  type    = "CNAME"
  content = data.cloudflare_zones.main_domain.result[0].name
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} CNAME to apex domain from www"

  proxied = local.proxy_default
}

resource "cloudflare_dns_record" "matrix" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = "matrix"
  type    = "A"
  content = var.matrix_ip
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} matrix server"

  proxied = local.proxy_default
}

resource "cloudflare_dns_record" "element" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = "element"
  type    = "A"
  content = var.matrix_ip
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} element client for matrix server"

  proxied = local.proxy_default
}

resource "cloudflare_dns_record" "cfp" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = "cfp"
  type    = "A"
  content = data.terraform_remote_state.pangolin.outputs.lh_instance_ipv4
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} cfp website"

  proxied = local.proxy_default
}

resource "cloudflare_dns_record" "cfpv6" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = "cfp"
  type    = "AAAA"
  content = data.terraform_remote_state.pangolin.outputs.lh_instance_ipv6
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} cfp website"

  proxied = local.proxy_default
}

resource "cloudflare_dns_record" "pangolin" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = var.pangolin_subdomain
  type    = "A"
  content = data.terraform_remote_state.pangolin.outputs.lh_instance_ipv4
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} pangolin server"

  # can't proxy because have non HTTP/HTTPS ports required (UDP)
  # https://community.cloudflare.com/t/questions-about-udp-and-gaming-servers-proxied-vs-dns/611856/3
  proxied = false
}

resource "cloudflare_dns_record" "pangolinv6" {
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  name    = var.pangolin_subdomain
  type    = "AAAA"
  content = data.terraform_remote_state.pangolin.outputs.lh_instance_ipv6
  ttl     = local.ttl_default
  comment = "${local.terraform_prefix} pangolin server"

  # can't proxy because have non HTTP/HTTPS ports required (UDP)
  # https://community.cloudflare.com/t/questions-about-udp-and-gaming-servers-proxied-vs-dns/611856/3
  proxied = false
}

# output "main_domain" {
#   value = data.cloudflare_zones.main_domain.result[0].id
# }
# output "www" {
#   value = resource.cloudflare_dns_record.www
# }