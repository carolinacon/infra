output "jitsi_instance_id" {
  description = "The ID of the Vultr instance"
  value       = vultr_instance.jitsi.id
}

output "jitsi_instance_ipv4" {
  description = "The main IPv4 address"
  value       = vultr_instance.jitsi.main_ip
}

output "jitsi_instance_ipv6" {
  description = "The main IPv6 address"
  value       = vultr_instance.jitsi.v6_main_ip
}
