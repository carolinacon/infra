locals {
  tags = [
    "production",
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

resource "vultr_instance" "jitsi" {
  plan        = var.plan
  region      = var.region
  os_id       = var.os_id
  hostname    = "jitsi"
  label = "jitsi"
  enable_ipv6 = true
  backups = "enabled"
  backups_schedule {
    type = "daily"
    hour = 05
  }
  ssh_key_ids = [
    data.vultr_ssh_key.shared_ssh.id
  ]

  tags = local.tags
}
