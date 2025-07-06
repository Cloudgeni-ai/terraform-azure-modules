output "id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "location" {
  description = "The location of the Key Vault"
  value       = azurerm_key_vault.this.location
}

output "resource_group_name" {
  description = "The name of the resource group in which the Key Vault is created"
  value       = azurerm_key_vault.this.resource_group_name
}

output "vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "tenant_id" {
  description = "The tenant ID of the Key Vault"
  value       = azurerm_key_vault.this.tenant_id
}

output "sku_name" {
  description = "The SKU name of the Key Vault"
  value       = azurerm_key_vault.this.sku_name
}

output "access_policy" {
  description = "The access policies of the Key Vault"
  value       = azurerm_key_vault.this.access_policy
}

output "secrets" {
  description = "Map of secrets created in the Key Vault"
  value = {
    for secret in azurerm_key_vault_secret.this : secret.name => {
      id           = secret.id
      name         = secret.name
      version      = secret.version
      versionless_id = secret.versionless_id
    }
  }
}

output "keys" {
  description = "Map of keys created in the Key Vault"
  value = {
    for key in azurerm_key_vault_key.this : key.name => {
      id           = key.id
      name         = key.name
      version      = key.version
      versionless_id = key.versionless_id
      key_type     = key.key_type
      key_size     = key.key_size
      curve        = key.curve
    }
  }
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)"
  value       = var.private_endpoint != null ? azurerm_private_endpoint.this["keyvault"].id : null
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting (if created)"
  value       = var.diagnostic_settings != null ? azurerm_monitor_diagnostic_setting.this[0].id : null
}

output "management_lock_id" {
  description = "The ID of the management lock (if created)"
  value       = var.create_management_lock ? azurerm_management_lock.this[0].id : null
}

output "tags" {
  description = "The tags assigned to the Key Vault"
  value       = azurerm_key_vault.this.tags
} 