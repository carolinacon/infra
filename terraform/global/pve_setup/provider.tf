provider "proxmox" {
  insecure = true
  # https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-connection
  ssh {
    # eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa
    agent = true
  }
}