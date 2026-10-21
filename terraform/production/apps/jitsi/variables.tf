variable "region" {
  description = "Vultr region to deploy to"
  type        = string
  default     = "ord"
}

variable "plan" {
  description = "Vultr server plan (vc2-1c-2gb is $10/month)"
  type        = string
  # default     = "vhp-4c-8gb"
  default     = "vhp-4c-8gb-amd"
}

variable "os_id" {
  description = "Operating system ID (2284 = Ubuntu 24.04)"
  type        = string
  default     = "2284"
}
