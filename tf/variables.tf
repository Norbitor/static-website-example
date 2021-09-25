variable "cloudflare_mail" {
  description = "Cloudflare Account E-mail"
  type        = string
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile Name"
  type        = string
  default     = "default"
}