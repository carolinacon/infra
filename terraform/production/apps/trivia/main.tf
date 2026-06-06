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

resource "vultr_instance" "ctfd" {
  plan        = var.plan
  region      = var.region
  os_id       = var.os_id
  hostname    = "trivia"
  label = "trivia"
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
