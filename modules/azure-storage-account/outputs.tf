output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "location" {
  description = "The location of the storage account"
  value       = azurerm_storage_account.this.location
}

output "resource_group_name" {
  description = "The name of the resource group in which the storage account is created"
  value       = azurerm_storage_account.this.resource_group_name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The primary blob host"
  value       = azurerm_storage_account.this.primary_blob_host
}

output "primary_queue_endpoint" {
  description = "The primary queue endpoint"
  value       = azurerm_storage_account.this.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The primary table endpoint"
  value       = azurerm_storage_account.this.primary_table_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint"
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_web_endpoint" {
  description = "The primary web endpoint"
  value       = azurerm_storage_account.this.primary_web_endpoint
}

output "primary_dfs_endpoint" {
  description = "The primary DFS endpoint"
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account"
  value       = azurerm_storage_account.this.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = azurerm_storage_account.this.secondary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "The primary blob connection string for the storage account"
  value       = azurerm_storage_account.this.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The secondary blob connection string for the storage account"
  value       = azurerm_storage_account.this.secondary_blob_connection_string
  sensitive   = true
}

output "identity" {
  description = "The identity information for the storage account"
  value = var.identity != null ? {
    type         = azurerm_storage_account.this.identity[0].type
    principal_id = azurerm_storage_account.this.identity[0].principal_id
    tenant_id    = azurerm_storage_account.this.identity[0].tenant_id
  } : null
}

output "containers" {
  description = "Map of container names to their properties"
  value = {
    for container in azurerm_storage_container.this : container.name => {
      id                    = container.id
      name                  = container.name
      container_access_type = container.container_access_type
      metadata              = container.metadata
    }
  }
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)"
  value       = var.private_endpoint != null ? azurerm_private_endpoint.this["storage"].id : null
}

output "management_lock_id" {
  description = "The ID of the management lock (if created)"
  value       = var.create_management_lock ? azurerm_management_lock.this[0].id : null
}

output "tags" {
  description = "The tags assigned to the storage account"
  value       = azurerm_storage_account.this.tags
} 