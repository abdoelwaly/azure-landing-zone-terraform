data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

module "private_endpoint" {
  source = "../private-endpoint"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  target_resource_id  = azurerm_key_vault.this.id
  subresource_name    = "vault"
  private_dns_zone_id = var.private_dns_zone_id
  tags                = var.tags
}

# Least privilege: readers only get secret values, admins manage them.
resource "azurerm_role_assignment" "secrets_user" {
  for_each = var.secret_reader_principal_ids

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "secrets_officer" {
  for_each = var.secret_admin_principal_ids

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value
}
