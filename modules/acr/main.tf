resource "azurerm_container_registry" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Premium" # Premium is required for private endpoints
  admin_enabled                 = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  data_endpoint_enabled         = true # dedicated, private data endpoint per region
  tags                          = var.tags

  retention_policy_in_days = 7
}

module "private_endpoint" {
  source = "../private-endpoint"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  target_resource_id  = azurerm_container_registry.this.id
  subresource_name    = "registry"
  private_dns_zone_id = var.private_dns_zone_id
  tags                = var.tags
}

# Identities that may pull images, for example the AKS kubelet identity.
resource "azurerm_role_assignment" "pull" {
  for_each = var.pull_principal_ids

  scope                            = azurerm_container_registry.this.id
  role_definition_name             = "AcrPull"
  principal_id                     = each.value
  skip_service_principal_aad_check = true
}
