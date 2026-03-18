variable "region" {
  description = "Vultr region to deploy to"
  type        = string
  default     = "ord"
}

variable "plan" {
  description = "Vultr server plan (vc2-1c-1gb is $5/month)"
  type        = string
  default     = "vc2-1c-1gb"
}

variable "os_id" {
  description = "Operating system ID (2284 = Ubuntu 24.04)"
  type        = string
  default     = "2284"
}
