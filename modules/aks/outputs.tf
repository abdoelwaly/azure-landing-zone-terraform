output "id" {
  description = "Cluster ID."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "kubelet_object_id" {
  description = "Object ID of the kubelet identity, used for AcrPull."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity federation."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "key_vault_secrets_provider_object_id" {
  description = "Object ID of the CSI secrets-store driver identity."
  value       = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}
