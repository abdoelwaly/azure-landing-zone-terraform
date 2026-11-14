variable "name" {
  description = "Registry name (globally unique, alphanumeric)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "ACR names must be 5-50 alphanumeric characters."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the registry."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the registry's private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the privatelink.azurecr.io zone."
  type        = string
}

variable "pull_principal_ids" {
  description = "Principal IDs granted AcrPull, keyed by a static label."
  type        = map(string)
  default     = {}
}

variable "zone_redundancy_enabled" {
  description = "Spread the registry across availability zones."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
