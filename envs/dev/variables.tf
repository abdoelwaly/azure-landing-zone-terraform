variable "workload" {
  description = "Short workload name used in resource names."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name: dev, test or prod."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "location_short" {
  description = "Short region code used in names."
  type        = string
  default     = "weu"
}

variable "hub_cidr" {
  description = "Address space of the hub VNet."
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke_cidr" {
  description = "Address space of the AKS spoke VNet."
  type        = string
  default     = "10.10.0.0/16"
}

variable "aks_admin_group_object_ids" {
  description = "Entra ID groups with cluster-admin."
  type        = list(string)
  default     = []
}

variable "aks_sku_tier" {
  description = "AKS tier: Free for dev, Standard for production."
  type        = string
  default     = "Free"
}

variable "aks_user_node_max_count" {
  description = "Upper bound for the workload node pool autoscaler."
  type        = number
  default     = 3
}

variable "log_daily_quota_gb" {
  description = "Daily ingestion cap for Log Analytics (-1 for none)."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Extra tags merged into every resource."
  type        = map(string)
  default     = {}
}
