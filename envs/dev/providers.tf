terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state in a storage account with Entra ID auth (no access keys).
  # Values come from backend.hcl: terraform init -backend-config=backend.hcl
  backend "azurerm" {
    use_azuread_auth = true
  }
}

# Subscription comes from ARM_SUBSCRIPTION_ID. In CI the pipeline signs in with
# OIDC (ARM_USE_OIDC=true), so no client secret is stored anywhere.
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  storage_use_azuread = true
}
