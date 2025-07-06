output "id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.this.location
}

output "tags" {
  description = "The tags assigned to the resource group"
  value       = azurerm_resource_group.this.tags
}

output "management_lock_id" {
  description = "The ID of the management lock (if created)"
  value       = var.create_management_lock ? azurerm_management_lock.this[0].id : null
} 