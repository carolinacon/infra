output "owncast_instance_id" {
  description = "The ID of the Vultr instance"
  value       = vultr_instance.owncast.id
}

output "owncast_instance_ipv4" {
  description = "The main IPv4 address"
  value       = vultr_instance.owncast.main_ip
}

output "owncast_instance_ipv6" {
  description = "The main IPv6 address"
  value       = vultr_instance.owncast.v6_main_ip
}
