locals {
  tags = [
    "production",
    "terraform"
  ]
}

data "vultr_ssh_key" "shared_ssh" {
  filter {
    name = "name"
    values = [ "shared-ssh" ]
  }
}

resource "vultr_instance" "definednet_lighthouse" {
  plan        = var.plan
  region      = var.region
  os_id       = var.os_id
  hostname    = "cc-lighthouse"
  label = "lighthouse"
  enable_ipv6 = true
  backups = "enabled"
  backups_schedule {
    type = "weekly"
  }
  ssh_key_ids = [
    data.vultr_ssh_key.shared_ssh.id
  ]

  tags = local.tags
}
