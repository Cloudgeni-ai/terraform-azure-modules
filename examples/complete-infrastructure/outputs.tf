# Resource Group Outputs
output "resource_group" {
  description = "Resource group information"
  value = {
    id       = module.resource_group.id
    name     = module.resource_group.name
    location = module.resource_group.location
  }
}

# Virtual Network Outputs
output "virtual_network" {
  description = "Virtual network information"
  value = {
    id            = module.virtual_network.id
    name          = module.virtual_network.name
    address_space = module.virtual_network.address_space
    subnet_ids    = module.virtual_network.subnet_ids
    ddos_protection_plan_id = module.virtual_network.ddos_protection_plan_id
  }
}

# Storage Account Outputs
output "storage_account" {
  description = "Storage account information"
  value = {
    id                   = module.storage_account.id
    name                 = module.storage_account.name
    primary_blob_endpoint = module.storage_account.primary_blob_endpoint
    containers           = module.storage_account.containers
    private_endpoint_id  = module.storage_account.private_endpoint_id
  }
}

# Storage Account Connection String (Sensitive)
output "storage_connection_string" {
  description = "Storage account primary connection string"
  value       = module.storage_account.primary_connection_string
  sensitive   = true
}

# Key Vault Outputs
output "key_vault" {
  description = "Key Vault information"
  value = {
    id                  = module.key_vault.id
    name                = module.key_vault.name
    vault_uri           = module.key_vault.vault_uri
    secrets             = keys(module.key_vault.secrets)
    keys                = keys(module.key_vault.keys)
    private_endpoint_id = module.key_vault.private_endpoint_id
  }
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "Summary of created infrastructure"
  value = {
    project_name = local.project_name
    environment  = local.environment
    location     = local.location
    resources = {
      resource_group_name  = module.resource_group.name
      virtual_network_name = module.virtual_network.name
      storage_account_name = module.storage_account.name
      key_vault_name       = module.key_vault.name
    }
    endpoints = {
      storage_blob_endpoint = module.storage_account.primary_blob_endpoint
      key_vault_uri         = module.key_vault.vault_uri
    }
    security_features = {
      ddos_protection     = true
      private_endpoints   = true
      network_acls        = true
      management_locks    = true
      rbac_authorization  = true
    }
  }
} 