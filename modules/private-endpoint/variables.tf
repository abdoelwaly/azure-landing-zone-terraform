variable "name" {
  description = "Short name used to build the endpoint and connection names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the private endpoint."
  type        = string
}

variable "subnet_id" {
  description = "Subnet the endpoint's NIC is placed in."
  type        = string
}

variable "target_resource_id" {
  description = "ID of the PaaS resource being exposed privately."
  type        = string
}

variable "subresource_name" {
  description = "Private link sub-resource, for example vault or registry."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone that receives the endpoint's A record."
  type        = string
}

variable "tags" {
  description = "Tags applied to the endpoint."
  type        = map(string)
  default     = {}
}
