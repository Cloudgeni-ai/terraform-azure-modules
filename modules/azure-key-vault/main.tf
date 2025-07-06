# Get current client configuration
data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # SKU
  sku_name = var.sku_name

  # Security settings
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  public_network_access_enabled   = var.public_network_access_enabled

  # Network access
  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  # Access policies (if not using RBAC)
  dynamic "access_policy" {
    for_each = var.enable_rbac_authorization ? [] : var.access_policies
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = access_policy.value.object_id

      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
    }
  }

  # Default access policy for current user (if not using RBAC)
  dynamic "access_policy" {
    for_each = var.enable_rbac_authorization ? [] : [1]
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id

      key_permissions = [
        "Create",
        "Get",
        "List",
        "Update",
        "Delete",
        "Purge",
        "Recover"
      ]

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge",
        "Recover"
      ]

      certificate_permissions = [
        "Get",
        "List",
        "Create",
        "Update",
        "Delete",
        "Purge",
        "Recover"
      ]
    }
  }

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-key-vault"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Private endpoint for Key Vault
resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint != null ? { "keyvault" = var.private_endpoint } : {}

  name                = "${azurerm_key_vault.this.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "${azurerm_key_vault.this.name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
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
      "Module"    = "azure-key-vault"
    }
  )
}

# Key Vault secrets
resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id

  content_type    = lookup(each.value, "content_type", null)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-key-vault"
    }
  )

  depends_on = [
    azurerm_key_vault.this
  ]
}

# Key Vault keys
resource "azurerm_key_vault_key" "this" {
  for_each = var.keys

  name         = each.value.name
  key_vault_id = azurerm_key_vault.this.id
  key_type     = each.value.key_type
  key_size     = lookup(each.value, "key_size", null)
  curve        = lookup(each.value, "curve", null)

  key_opts = each.value.key_opts

  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-key-vault"
    }
  )

  depends_on = [
    azurerm_key_vault.this
  ]
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings != null ? 1 : 0

  name                       = "${azurerm_key_vault.this.name}-diagnostics"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.diagnostic_settings.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Management lock
resource "azurerm_management_lock" "this" {
  count = var.create_management_lock ? 1 : 0

  name       = "${azurerm_key_vault.this.name}-lock"
  scope      = azurerm_key_vault.this.id
  lock_level = var.management_lock_level
  notes      = var.management_lock_notes
} 