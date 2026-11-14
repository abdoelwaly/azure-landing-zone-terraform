output "aks_name" {
  description = "AKS cluster name."
  value       = module.aks.name
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer for workload identity federation."
  value       = module.aks.oidc_issuer_url
}

output "acr_login_server" {
  description = "Container registry login server."
  value       = module.acr.login_server
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.keyvault.vault_uri
}

output "workload_resource_group" {
  description = "Resource group holding the workload."
  value       = azurerm_resource_group.workload.name
}
