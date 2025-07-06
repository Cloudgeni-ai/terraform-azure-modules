# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  dns_servers = var.dns_servers

  # DDoS protection configuration
  dynamic "ddos_protection_plan" {
    for_each = var.create_ddos_protection_plan ? [1] : []
    content {
      id     = azurerm_network_ddos_protection_plan.this[0].id
      enable = true
    }
  }

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-virtual-network"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Subnets
resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]

  # Optional service endpoints
  service_endpoints = lookup(each.value, "service_endpoints", [])

  # Optional delegation
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Network Security Groups for subnets (if enabled)
resource "azurerm_network_security_group" "subnet_nsg" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if lookup(subnet, "create_nsg", false) }

  name                = "${each.value.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-virtual-network"
      "SubnetNSG" = each.value.name
    }
  )
}

# Default security rules for NSGs
resource "azurerm_network_security_rule" "default_deny_all" {
  for_each = azurerm_network_security_group.subnet_nsg

  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = each.value.name
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = azurerm_network_security_group.subnet_nsg

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.id
}

# Optional: DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "this" {
  count = var.create_ddos_protection_plan ? 1 : 0

  name                = "${var.name}-ddos-plan"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-virtual-network"
    }
  )
}

