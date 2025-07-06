output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}

output "nsg_name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.main.name
}

output "nsg_resource_group_name" {
  description = "Resource group name of the Network Security Group"
  value       = azurerm_network_security_group.main.resource_group_name
}

output "nsg_location" {
  description = "Location of the Network Security Group"
  value       = azurerm_network_security_group.main.location
}

output "nsg_tags" {
  description = "Tags applied to the Network Security Group"
  value       = azurerm_network_security_group.main.tags
}

output "security_rules" {
  description = "Map of security rules created"
  value = {
    for rule_name, rule in azurerm_network_security_rule.rules : rule_name => {
      id                         = rule.id
      name                       = rule.name
      priority                   = rule.priority
      direction                  = rule.direction
      access                     = rule.access
      protocol                   = rule.protocol
      source_port_range          = rule.source_port_range
      source_port_ranges         = rule.source_port_ranges
      destination_port_range     = rule.destination_port_range
      destination_port_ranges    = rule.destination_port_ranges
      source_address_prefix      = rule.source_address_prefix
      source_address_prefixes    = rule.source_address_prefixes
      destination_address_prefix = rule.destination_address_prefix
      destination_address_prefixes = rule.destination_address_prefixes
      description                = rule.description
    }
  }
}

output "subnet_associations" {
  description = "Map of subnet associations"
  value = {
    for subnet_id in var.associated_subnet_ids : subnet_id => {
      id                        = azurerm_subnet_network_security_group_association.main[subnet_id].id
      subnet_id                 = azurerm_subnet_network_security_group_association.main[subnet_id].subnet_id
      network_security_group_id = azurerm_subnet_network_security_group_association.main[subnet_id].network_security_group_id
    }
  }
}

output "network_interface_associations" {
  description = "Map of network interface associations"
  value = {
    for nic_id in var.associated_network_interface_ids : nic_id => {
      id                        = azurerm_network_interface_security_group_association.main[nic_id].id
      network_interface_id      = azurerm_network_interface_security_group_association.main[nic_id].network_interface_id
      network_security_group_id = azurerm_network_interface_security_group_association.main[nic_id].network_security_group_id
    }
  }
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = var.enable_diagnostic_setting ? azurerm_monitor_diagnostic_setting.main[0].id : null
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace used for diagnostics"
  value       = var.enable_diagnostic_setting ? (var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.main[0].id) : null
}

output "management_lock_id" {
  description = "ID of the management lock"
  value       = var.enable_management_lock ? azurerm_management_lock.main[0].id : null
}

output "predefined_rules_enabled" {
  description = "List of predefined rules that were enabled"
  value       = var.predefined_rules_enabled
}

output "custom_security_rules_count" {
  description = "Number of custom security rules created"
  value       = length(var.custom_security_rules)
}

output "total_security_rules_count" {
  description = "Total number of security rules created"
  value       = length(local.all_security_rules)
}

output "random_suffix" {
  description = "Random suffix used in naming (if enabled)"
  value       = var.use_random_suffix ? random_string.nsg_suffix[0].result : null
} 