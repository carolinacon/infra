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

variable "bucket_name" {
  description = "Name of the R2 bucket"
  type        = string
  default     = "pretalx-assets"
}

###############################################################################
# Provider
###############################################################################

provider "cloudflare" {}

###############################################################################
# R2 Bucket
###############################################################################

resource "cloudflare_r2_bucket" "pretalx" {
  account_id = var.cloudflare_account_id
  name       = var.bucket_name
  location   = "ENAM"
}

###############################################################################
# Optional: Lifecycle Rules
#
# These rules:
# - Abort incomplete multipart uploads after 7 days
# - Transition old backups to infrequent access after 30 days
#
# Adjust to fit your retention requirements.
###############################################################################

resource "cloudflare_r2_bucket_lifecycle" "pretalx" {
  account_id = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.pretalx.name

  rules = [
    {
      id      = "cleanup-multipart-uploads"
      enabled = true

      conditions = {
        prefix = ""
      }

      abort_multipart_uploads_transition = {
        condition = {
          type    = "Age"
          max_age = 604800
        }
      }
    },

    {
      id      = "backup-tiering"
      enabled = true

      conditions = {
        prefix = "backups/"
      }

      storage_class_transitions = [
        {
          storage_class = "InfrequentAccess"

          condition = {
            type    = "Age"
            max_age = 2592000
          }
        }
      ]
    }
  ]
}

data "terraform_remote_state" "pretalx" {
  backend = "s3"
  config = {
    bucket       = "ccon-tfstate"
    key          = "production/apps/pretalx/terraform.tfstate"
    region       = "us-west-2"
  }
}

data "terraform_remote_state" "pretalx_dev" {
  backend = "s3"
  config = {
    bucket       = "ccon-tfstate"
    key          = "development/apps/pretalx/terraform.tfstate"
    region       = "us-west-2"
  }
}

resource "cloudflare_account_token" "pretalx_account_token" {
  account_id = var.cloudflare_account_id
  name       = "pretalx-r2-access-cold-feather-92d3"

  policies = [{
    effect = "allow"
    permission_groups = [{
      id = "2efd5506f9c8494dacb1fa10a3e7d5b6"
      }, {
      id = "6a018a9f2fc74eb6b293b0c548f38b39"
    }]
    resources = jsonencode({
      "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_pretalx-assets" = "*"
    })
  }]
  ## Not working correctly...even when from legit IP it fails...
  # condition = {
  #   request_ip = {
  #     in     = [
  #       "${data.terraform_remote_state.pretalx.outputs.pretalx_instance_ipv4}/32",
  #       "${data.terraform_remote_state.pretalx_dev.outputs.pretalx_instance_ipv4}/32"
  #       ]
  #   }
  # }
}
###############################################################################
# Outputs
###############################################################################

output "bucket_name" {
  value = cloudflare_r2_bucket.pretalx.name
}

output "s3_endpoint" {
  value = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

output "pretalx_access_key" {
  value = cloudflare_account_token.pretalx_account_token.id
  sensitive = true
}
output "pretalx_secret_key" {
  value = cloudflare_account_token.pretalx_account_token.value
  sensitive = true
}
output "pretalx_secret_key_r2_format" {
  value = sha256(cloudflare_account_token.pretalx_account_token.value)
  sensitive = true
}