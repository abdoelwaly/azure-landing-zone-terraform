variable "name" {
  description = "Key Vault name (globally unique, 3-24 characters)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the vault."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the vault's private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the privatelink.vaultcore.azure.net zone."
  type        = string
}

variable "secret_reader_principal_ids" {
  description = "Principals that can read secret values, keyed by a static label."
  type        = map(string)
  default     = {}
}

variable "secret_admin_principal_ids" {
  description = "Principals that can manage secrets, keyed by a static label."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
