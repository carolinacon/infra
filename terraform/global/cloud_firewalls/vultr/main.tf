############################################################
# Lookup trusted host addresses from another Terraform state
############################################################
data "terraform_remote_state" "jumpbox" {
  backend = "s3"

  config = {
    bucket       = "ccon-tfstate"
    key          = "production/network/terraform.tfstate"
    region       = "us-west-2"
  }
}

data "http" "current_ip" {
  url = "https://api.ipify.org/?format=json"
}

############################################################
# Firewall Group
############################################################

resource "vultr_firewall_group" "trusted_only" {
  description = "Allow all traffic only from trusted jumpbox"
}
resource "vultr_firewall_group" "trusted_only_dev" {
  description = "Allow all traffic for dev servers"
}

############################################################
# IPv4 Rules
############################################################

resource "vultr_firewall_rule" "allow_ipv4_tcp" {
  firewall_group_id = vultr_firewall_group.trusted_only.id

  protocol    = "tcp"
  ip_type     = "v4"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv4
  subnet_size = 32

  port = "1:65535"
}

resource "vultr_firewall_rule" "allow_ipv4_udp" {
  firewall_group_id = vultr_firewall_group.trusted_only.id

  protocol    = "udp"
  ip_type     = "v4"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv4
  subnet_size = 32

  port = "1:65535"
}

resource "vultr_firewall_rule" "dev_allow_ipv4_tcp" {
  firewall_group_id = vultr_firewall_group.trusted_only_dev.id

  protocol    = "tcp"
  ip_type     = "v4"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv4
  subnet_size = 32

  port = "1:65535"
}

resource "vultr_firewall_rule" "dev_allow_ipv4_udp" {
  firewall_group_id = vultr_firewall_group.trusted_only_dev.id

  protocol    = "udp"
  ip_type     = "v4"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv4
  subnet_size = 32

  port = "1:65535"
}

resource "vultr_firewall_rule" "dev_allow_home_ipv4_tcp" {
  firewall_group_id = vultr_firewall_group.trusted_only_dev.id

  protocol    = "tcp"
  ip_type     = "v4"
  subnet      = jsondecode(data.http.current_ip.response_body).ip
  subnet_size = 32

  port = "1:65535"
}

resource "vultr_firewall_rule" "dev_allow_home_ipv4_udp" {
  firewall_group_id = vultr_firewall_group.trusted_only_dev.id

  protocol    = "udp"
  ip_type     = "v4"
  subnet      = jsondecode(data.http.current_ip.response_body).ip
  subnet_size = 32

  port = "1:65535"
}

############################################################
# IPv6 Rules
############################################################

resource "vultr_firewall_rule" "allow_ipv6_tcp" {
  firewall_group_id = vultr_firewall_group.trusted_only.id

  protocol    = "tcp"
  ip_type     = "v6"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv6
  subnet_size = 128

  port = "1:65535"
}

resource "vultr_firewall_rule" "allow_ipv6_udp" {
  firewall_group_id = vultr_firewall_group.trusted_only.id

  protocol    = "udp"
  ip_type     = "v6"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv6
  subnet_size = 128

  port = "1:65535"
}

resource "vultr_firewall_rule" "dev_allow_ipv6_tcp" {
  firewall_group_id = vultr_firewall_group.trusted_only_dev.id

  protocol    = "tcp"
  ip_type     = "v6"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv6
  subnet_size = 128

  port = "1:65535"
}

resource "vultr_firewall_rule" "dev_allow_ipv6_udp" {
  firewall_group_id = vultr_firewall_group.trusted_only_dev.id

  protocol    = "udp"
  ip_type     = "v6"
  subnet      = data.terraform_remote_state.jumpbox.outputs.lh_instance_ipv6
  subnet_size = 128

  port = "1:65535"
}

############################################################
# Attach firewall to server
############################################################
output "firewall_group_id" {
  value = vultr_firewall_group.trusted_only.id
  description = "allow traffic only from trusted server (jumphost/pangolin)"
}
output "dev_firewall_group_id" {
  value = vultr_firewall_group.trusted_only_dev.id
  description = "dev allow traffic only from trusted server (jumphost/pangolin)"
}