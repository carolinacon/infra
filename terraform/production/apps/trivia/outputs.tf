output "ctfd_instance_id" {
  description = "The ID of the Vultr instance"
  value       = vultr_instance.ctfd.id
}

output "ctfd_instance_ipv4" {
  description = "The main IPv4 address"
  value       = vultr_instance.ctfd.main_ip
}

output "ctfd_instance_ipv6" {
  description = "The main IPv6 address"
  value       = vultr_instance.ctfd.v6_main_ip
}
