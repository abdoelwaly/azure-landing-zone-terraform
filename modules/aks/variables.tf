variable "name" {
  description = "Cluster name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version. Patch upgrades are automatic."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Free or Standard (Standard adds the uptime SLA)."
  type        = string
  default     = "Standard"
}

variable "node_subnet_id" {
  description = "Subnet for cluster nodes."
  type        = string
}

variable "zones" {
  description = "Availability zones for node pools."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "system_node_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "user_node_vm_size" {
  description = "VM size for the user (workload) node pool."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "user_node_min_count" {
  description = "Minimum nodes in the user pool."
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "Maximum nodes in the user pool."
  type        = number
  default     = 5
}

variable "pod_cidr" {
  description = "Overlay CIDR for pods. Must not overlap any VNet."
  type        = string
  default     = "192.168.0.0/16"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services. Must not overlap any VNet."
  type        = string
  default     = "172.16.0.0/16"
}

variable "admin_group_object_ids" {
  description = "Entra ID groups that get cluster-admin through Azure RBAC."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Workspace for Container Insights."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
