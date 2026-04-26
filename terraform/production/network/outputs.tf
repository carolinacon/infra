output "lh_instance_id" {
  description = "The ID of the Vultr instance"
  value       = vultr_instance.wg_vpn.id
}

output "lh_instance_ipv4" {
  description = "The main IPv4 address"
  value       = vultr_instance.wg_vpn.main_ip
}

output "lh_instance_ipv6" {
  description = "The main IPv6 address"
  value       = vultr_instance.wg_vpn.v6_main_ip
}
