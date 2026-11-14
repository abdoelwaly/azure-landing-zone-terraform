data "azurerm_client_config" "current" {}

# Control-plane identity. A user-assigned identity lets us grant it rights on the
# node subnet before the cluster exists.
resource "azurerm_user_assigned_identity" "control_plane" {
  name                = "id-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "subnet_network_contributor" {
  scope                = var.node_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  tags                = var.tags

  private_cluster_enabled   = true
  private_dns_zone_id       = "System"
  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = true
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    vnet_subnet_id               = var.node_subnet_id
    zones                        = var.zones
    only_critical_addons_enabled = true
    host_encryption_enabled      = true # needs the EncryptionAtHost feature on the subscription
    max_pods                     = 110
    auto_scaling_enabled         = true
    min_count                    = 2
    max_count                    = 3
    os_disk_type                 = "Ephemeral"
    os_disk_size_gb              = 64

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.control_plane.id]
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = cidrhost(var.service_cidr, 10)
    load_balancer_sku   = "standard"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Saturday"
    start_time  = "02:00"
    duration    = 4
    utc_offset  = "+02:00"
  }

  lifecycle {
    ignore_changes = [kubernetes_version, default_node_pool[0].node_count]
  }

  depends_on = [azurerm_role_assignment.subnet_network_contributor]
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                    = "user"
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.this.id
  vm_size                 = var.user_node_vm_size
  vnet_subnet_id          = var.node_subnet_id
  zones                   = var.zones
  mode                    = "User"
  host_encryption_enabled = true
  max_pods                = 110
  auto_scaling_enabled    = true
  min_count               = var.user_node_min_count
  max_count               = var.user_node_max_count
  os_disk_type            = "Ephemeral"
  os_disk_size_gb         = 64
  tags                    = var.tags

  upgrade_settings {
    max_surge = "33%"
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}
