output "pretalx_instance_id" {
  description = "The ID of the Vultr instance"
  value       = vultr_instance.pretalx.id
}

output "pretalx_instance_ipv4" {
  description = "The main IPv4 address"
  value       = vultr_instance.pretalx.main_ip
}

output "pretalx_instance_ipv6" {
  description = "The main IPv6 address"
  value       = vultr_instance.pretalx.v6_main_ip
}
