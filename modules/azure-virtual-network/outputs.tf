output "id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "location" {
  description = "The location of the virtual network"
  value       = azurerm_virtual_network.this.location
}

output "resource_group_name" {
  description = "The name of the resource group in which the virtual network is created"
  value       = azurerm_virtual_network.this.resource_group_name
}

output "address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.this.address_space
}

output "dns_servers" {
  description = "The DNS servers of the virtual network"
  value       = azurerm_virtual_network.this.dns_servers
}

output "subnets" {
  description = "Map of subnet names to their configurations"
  value = {
    for subnet in azurerm_subnet.this : subnet.name => {
      id               = subnet.id
      name             = subnet.name
      address_prefixes = subnet.address_prefixes
      service_endpoints = subnet.service_endpoints
    }
  }
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for subnet in azurerm_subnet.this : subnet.name => subnet.id
  }
}

output "network_security_groups" {
  description = "Map of subnet names to their NSG IDs (if created)"
  value = {
    for nsg in azurerm_network_security_group.subnet_nsg : nsg.name => nsg.id
  }
}

output "ddos_protection_plan_id" {
  description = "The ID of the DDoS protection plan (if created)"
  value       = var.create_ddos_protection_plan ? azurerm_network_ddos_protection_plan.this[0].id : null
}

output "tags" {
  description = "The tags assigned to the virtual network"
  value       = azurerm_virtual_network.this.tags
} 