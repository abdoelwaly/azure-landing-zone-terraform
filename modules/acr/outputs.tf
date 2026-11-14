output "id" {
  description = "Registry ID."
  value       = azurerm_container_registry.this.id
}

output "login_server" {
  description = "Registry login server, for example myacr.azurecr.io."
  value       = azurerm_container_registry.this.login_server
}
