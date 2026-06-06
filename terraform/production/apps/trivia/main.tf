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

data "terraform_remote_state" "cloud_fw" {
  backend = "s3"

  config = {
    bucket       = "ccon-tfstate"
    key          = "global/cloud_firewalls/vultr/terraform.tfstate"
    region       = "us-west-2"
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
  firewall_group_id = data.terraform_remote_state.cloud_fw.outputs.firewall_group_id

  tags = local.tags
}
