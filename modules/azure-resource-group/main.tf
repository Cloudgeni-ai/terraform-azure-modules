resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-resource-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Optional: Create a management lock to prevent accidental deletion
resource "azurerm_management_lock" "this" {
  count = var.create_management_lock ? 1 : 0

  name       = "${var.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = var.management_lock_level
  notes      = var.management_lock_notes
} 