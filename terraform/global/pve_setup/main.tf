terraform {
  required_version = ">= 1.1"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.108.0"
    }
  }
}

variable "tgt_node" {
  type = string
  description = "Target proxmox node to deploy vm to."
}

locals {
  handles_disabled = toset(["enterprise","ceph-squid-enterprise"])
  handles_enabled = toset(["no-subscription"])
}

# repo management

resource "proxmox_apt_standard_repository" "repo_disabled" {
  for_each = local.handles_disabled
  handle   = each.value
  node     = var.tgt_node
}

resource "proxmox_apt_repository" "repo_disabled" {
  for_each  = proxmox_apt_standard_repository.repo_disabled
  enabled   = false
  file_path = each.value.file_path
  index     = each.value.index
  node      = each.value.node
}

resource "proxmox_apt_standard_repository" "repo_enabled" {
  for_each = local.handles_enabled
  handle   = each.value
  node     = var.tgt_node
}

resource "proxmox_apt_repository" "repo_enabled" {
  for_each  = proxmox_apt_standard_repository.repo_enabled
  enabled   = true
  file_path = each.value.file_path
  index     = each.value.index
  node      = each.value.node
}

# iso management