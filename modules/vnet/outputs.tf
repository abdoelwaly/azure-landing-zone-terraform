output "id" {
  description = "Virtual network ID."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Virtual network name."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet name."
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}
