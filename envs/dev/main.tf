locals {
  name   = "${var.workload}-${var.environment}-${var.location_short}"
  suffix = random_string.suffix.result

  tags = merge(var.tags, {
    environment = var.environment
    workload    = var.workload
    managed_by  = "terraform"
  })

  private_dns_zones = {
    keyvault = "privatelink.vaultcore.azure.net"
    acr      = "privatelink.azurecr.io"
  }
}

# Short random suffix for globally unique names (Key Vault, ACR).
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "connectivity" {
  name     = "rg-${local.name}-connectivity"
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-${local.name}-workload"
  location = var.location
  tags     = local.tags
}

# ---------------------------------------------------------------- networking

module "hub" {
  source = "../../modules/vnet"

  name                = "vnet-${local.name}-hub"
  location            = var.location
  resource_group_name = azurerm_resource_group.connectivity.name
  address_space       = [var.hub_cidr]
  tags                = local.tags

  subnets = {
    snet-shared = {
      address_prefixes = [cidrsubnet(var.hub_cidr, 8, 1)]
    }
    snet-private-endpoints = {
      address_prefixes = [cidrsubnet(var.hub_cidr, 8, 2)]
    }
  }
}

module "spoke_aks" {
  source = "../../modules/vnet"

  name                = "vnet-${local.name}-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  address_space       = [var.spoke_cidr]
  tags                = local.tags

  subnets = {
    snet-aks-nodes = {
      # /20 leaves room for ~4000 nodes with Azure CNI overlay.
      address_prefixes = [cidrsubnet(var.spoke_cidr, 4, 0)]
      create_nsg       = false # AKS manages its own NSG on the node resource group
    }
    snet-private-endpoints = {
      address_prefixes = [cidrsubnet(var.spoke_cidr, 8, 16)]
      nsg_rules = [{
        name                       = "allow-https-from-vnet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }]
    }
  }
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-aks"
  resource_group_name          = azurerm_resource_group.connectivity.name
  virtual_network_name         = module.hub.name
  remote_virtual_network_id    = module.spoke_aks.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-aks-to-hub"
  resource_group_name          = azurerm_resource_group.workload.name
  virtual_network_name         = module.spoke_aks.name
  remote_virtual_network_id    = module.hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# Private DNS lives in the hub and is linked to every VNet that resolves it.
resource "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zones

  name                = each.value
  resource_group_name = azurerm_resource_group.connectivity.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.this

  name                  = "link-hub"
  resource_group_name   = azurerm_resource_group.connectivity.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = module.hub.id
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_aks" {
  for_each = azurerm_private_dns_zone.this

  name                  = "link-aks"
  resource_group_name   = azurerm_resource_group.connectivity.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = module.spoke_aks.id
  tags                  = local.tags
}

# ---------------------------------------------------------------- monitoring

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${local.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = var.log_daily_quota_gb
  tags                = local.tags
}

# ---------------------------------------------------------------- workload

module "aks" {
  source = "../../modules/aks"

  name                       = "aks-${local.name}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.workload.name
  node_subnet_id             = module.spoke_aks.subnet_ids["snet-aks-nodes"]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  admin_group_object_ids     = var.aks_admin_group_object_ids
  sku_tier                   = var.aks_sku_tier
  user_node_max_count        = var.aks_user_node_max_count
  tags                       = local.tags
}

module "acr" {
  source = "../../modules/acr"

  name                       = replace("acr${var.workload}${var.environment}${local.suffix}", "-", "")
  location                   = var.location
  resource_group_name        = azurerm_resource_group.workload.name
  private_endpoint_subnet_id = module.spoke_aks.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = azurerm_private_dns_zone.this["acr"].id
  zone_redundancy_enabled    = var.environment == "prod"
  tags                       = local.tags

  pull_principal_ids = {
    aks_kubelet = module.aks.kubelet_object_id
  }
}

module "keyvault" {
  source = "../../modules/keyvault"

  name                       = "kv-${var.workload}-${var.environment}-${local.suffix}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.workload.name
  private_endpoint_subnet_id = module.spoke_aks.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = azurerm_private_dns_zone.this["keyvault"].id
  tags                       = local.tags

  secret_reader_principal_ids = {
    aks_csi_driver = module.aks.key_vault_secrets_provider_object_id
  }
}
