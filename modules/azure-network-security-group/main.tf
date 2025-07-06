locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Module = "azure-network-security-group"
  })

  # Predefined security rules for common scenarios
  predefined_rules = {
    # Web tier rules
    "AllowHTTP" = {
      name                       = "AllowHTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP traffic"
    }
    "AllowHTTPS" = {
      name                       = "AllowHTTPS"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTPS traffic"
    }
    # Database tier rules
    "AllowSQL" = {
      name                       = "AllowSQL"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow SQL Server traffic from VNet"
    }
    "AllowMySQL" = {
      name                       = "AllowMySQL"
      priority                   = 201
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow MySQL traffic from VNet"
    }
    "AllowPostgreSQL" = {
      name                       = "AllowPostgreSQL"
      priority                   = 202
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow PostgreSQL traffic from VNet"
    }
    # Management rules
    "AllowSSH" = {
      name                       = "AllowSSH"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow SSH traffic from VNet"
    }
    "AllowRDP" = {
      name                       = "AllowRDP"
      priority                   = 301
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow RDP traffic from VNet"
    }
    # Deny all other inbound traffic
    "DenyAllInbound" = {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other inbound traffic"
    }
  }

  # Filter predefined rules based on enabled rules
  enabled_predefined_rules = {
    for rule_name, rule in local.predefined_rules : rule_name => rule
    if contains(var.predefined_rules_enabled, rule_name)
  }

  # Merge predefined and custom rules
  all_security_rules = merge(local.enabled_predefined_rules, var.custom_security_rules)
}

# Random suffix for unique NSG naming
resource "random_string" "nsg_suffix" {
  count   = var.use_random_suffix ? 1 : 0
  length  = 4
  special = false
  upper   = false
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = var.use_random_suffix ? "${var.name}-${random_string.nsg_suffix[0].result}" : var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.common_tags
}

# Security Rules
resource "azurerm_network_security_rule" "rules" {
  for_each = local.all_security_rules

  name                                       = each.value.name
  priority                                   = each.value.priority
  direction                                  = each.value.direction
  access                                     = each.value.access
  protocol                                   = each.value.protocol
  source_port_range                          = lookup(each.value, "source_port_range", null)
  source_port_ranges                         = lookup(each.value, "source_port_ranges", null)
  destination_port_range                     = lookup(each.value, "destination_port_range", null)
  destination_port_ranges                    = lookup(each.value, "destination_port_ranges", null)
  source_address_prefix                      = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes                    = lookup(each.value, "source_address_prefixes", null)
  source_application_security_group_ids      = lookup(each.value, "source_application_security_group_ids", null)
  destination_address_prefix                 = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes               = lookup(each.value, "destination_address_prefixes", null)
  destination_application_security_group_ids = lookup(each.value, "destination_application_security_group_ids", null)
  description                                = lookup(each.value, "description", null)

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name

  depends_on = [azurerm_network_security_group.main]
}

# Subnet Association
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = toset(var.associated_subnet_ids)

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.main.id
}

# Network Interface Association
resource "azurerm_network_interface_security_group_association" "main" {
  for_each = toset(var.associated_network_interface_ids)

  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.main.id
}

# Log Analytics Workspace (conditional)
resource "azurerm_log_analytics_workspace" "main" {
  count = var.enable_diagnostic_setting && var.log_analytics_workspace_id == null ? 1 : 0

  name                = "${azurerm_network_security_group.main.name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.enable_diagnostic_setting ? 1 : 0

  name                           = "${azurerm_network_security_group.main.name}-diag"
  target_resource_id             = azurerm_network_security_group.main.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.main[0].id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Management Lock
resource "azurerm_management_lock" "main" {
  count = var.enable_management_lock ? 1 : 0

  name       = "${azurerm_network_security_group.main.name}-lock"
  scope      = azurerm_network_security_group.main.id
  lock_level = var.management_lock_level
  notes      = var.management_lock_notes
} 