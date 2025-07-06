# Generate random suffix for globally unique storage account name
resource "random_id" "storage_account_suffix" {
  byte_length = 4
}

# Storage Account
resource "azurerm_storage_account" "this" {
  name                     = var.name_override != null ? var.name_override : "${var.name}${random_id.storage_account_suffix.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security settings
  https_traffic_only_enabled      = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  default_to_oauth_authentication = var.default_to_oauth_authentication

  # Network rules
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  # Blob properties
  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? [var.blob_properties] : []
    content {
      versioning_enabled            = blob_properties.value.versioning_enabled
      change_feed_enabled           = blob_properties.value.change_feed_enabled
      change_feed_retention_in_days = blob_properties.value.change_feed_retention_in_days
      default_service_version       = blob_properties.value.default_service_version
      last_access_time_enabled      = blob_properties.value.last_access_time_enabled

      dynamic "cors_rule" {
        for_each = blob_properties.value.cors_rule != null ? [blob_properties.value.cors_rule] : []
        content {
          allowed_origins    = cors_rule.value.allowed_origins
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_headers    = cors_rule.value.allowed_headers
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy != null ? [blob_properties.value.delete_retention_policy] : []
        content {
          days = delete_retention_policy.value.days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy != null ? [blob_properties.value.container_delete_retention_policy] : []
        content {
          days = container_delete_retention_policy.value.days
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-storage-account"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Storage containers
resource "azurerm_storage_container" "this" {
  for_each = { for container in var.containers : container.name => container }

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.container_access_type

  metadata = lookup(each.value, "metadata", {})
}

# Private endpoint for storage account
resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint != null ? { "storage" = var.private_endpoint } : {}

  name                = "${azurerm_storage_account.this.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.this.name}-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-storage-account"
    }
  )
}

# Management lock
resource "azurerm_management_lock" "this" {
  count = var.create_management_lock ? 1 : 0

  name       = "${azurerm_storage_account.this.name}-lock"
  scope      = azurerm_storage_account.this.id
  lock_level = var.management_lock_level
  notes      = var.management_lock_notes
} 