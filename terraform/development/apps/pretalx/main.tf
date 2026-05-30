locals {
  tags = [
    "development",
    "terraform",
    "apps"
  ]
}

data "vultr_ssh_key" "shared_ssh" {
  filter {
    name = "name"
    values = [ "shared-ssh" ]
  }
}

resource "vultr_instance" "pretalx" {
  plan        = var.plan
  region      = var.region
  os_id       = var.os_id
  hostname    = "pretalx-dev"
  label = "pretalx-dev"
  enable_ipv6 = true
  ssh_key_ids = [
    data.vultr_ssh_key.shared_ssh.id
  ]

  tags = local.tags
}
