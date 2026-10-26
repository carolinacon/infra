variable "region" {
  description = "Vultr region to deploy to"
  type        = string
  default     = "ord"
}

variable "plan" {
  description = "Vultr server plan (vc2-1c-2gb is $10/month)"
  type        = string
  default     = "voc-c-16c-32gb-300s"
  # default     = "vcg-a16-6c-60g-16vram"
  # default     = "vcg-a16-12c-120g-32vram"
}

variable "os_id" {
  description = "Operating system ID (2284 = Ubuntu 24.04)"
  type        = string
  default     = "2284"
}
