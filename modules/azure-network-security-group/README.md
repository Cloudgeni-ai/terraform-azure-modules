# Azure Network Security Group Module

This module creates an Azure Network Security Group (NSG) with predefined security rules and supports custom rules, subnet associations, and comprehensive monitoring.

## Features

- **Predefined Security Rules**: Common security rules for web, database, and management tiers
- **Custom Security Rules**: Support for custom security rules with full configuration options
- **Subnet Association**: Automatic association with specified subnets
- **Network Interface Association**: Support for network interface associations
- **Diagnostic Settings**: Built-in support for NSG flow logs and event logging
- **Management Lock**: Optional resource protection with management locks
- **Comprehensive Validation**: Input validation for all security rule parameters
- **Flexible Naming**: Optional random suffix for unique naming

## Usage

### Basic Usage

```hcl
module "basic_nsg" {
  source = "./modules/azure-network-security-group"

  name                = "web-nsg"
  resource_group_name = "example-rg"
  location            = "East US"

  predefined_rules_enabled = [
    "AllowHTTP",
    "AllowHTTPS",
    "DenyAllInbound"
  ]

  tags = {
    Environment = "development"
    Project     = "web-app"
  }
}
```

### Web Tier NSG

```hcl
module "web_nsg" {
  source = "./modules/azure-network-security-group"

  name                = "web-tier-nsg"
  resource_group_name = "web-rg"
  location            = "East US"

  predefined_rules_enabled = [
    "AllowHTTP",
    "AllowHTTPS",
    "AllowSSH",
    "DenyAllInbound"
  ]

  associated_subnet_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/main-vnet/subnets/web-subnet"
  ]

  enable_diagnostic_setting = true
  enable_management_lock    = true

  tags = {
    Environment = "production"
    Tier        = "web"
  }
}
```

### Database Tier NSG

```hcl
module "db_nsg" {
  source = "./modules/azure-network-security-group"

  name                = "db-tier-nsg"
  resource_group_name = "db-rg"
  location            = "East US"

  predefined_rules_enabled = [
    "AllowSQL",
    "AllowSSH",
    "DenyAllInbound"
  ]

  custom_security_rules = {
    "AllowAppTierToSQL" = {
      name                       = "AllowAppTierToSQL"
      priority                   = 150
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "10.0.2.0/24"  # App tier subnet
      destination_address_prefix = "*"
      description                = "Allow SQL traffic from app tier"
    }
  }

  associated_subnet_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/main-vnet/subnets/db-subnet"
  ]

  enable_diagnostic_setting = true
  enable_management_lock    = true
  management_lock_level     = "CanNotDelete"

  tags = {
    Environment = "production"
    Tier        = "database"
  }
}
```

### Advanced Custom Rules

```hcl
module "advanced_nsg" {
  source = "./modules/azure-network-security-group"

  name                = "advanced-nsg"
  resource_group_name = "advanced-rg"
  location            = "East US"

  custom_security_rules = {
    "AllowSpecificPorts" = {
      name                    = "AllowSpecificPorts"
      priority                = 200
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_ranges = ["8080", "8443", "9000"]
      source_address_prefixes = ["10.0.0.0/8", "192.168.0.0/16"]
      destination_address_prefix = "*"
      description             = "Allow specific ports from private networks"
    }
    "DenyHighRiskPorts" = {
      name                   = "DenyHighRiskPorts"
      priority               = 300
      direction              = "Inbound"
      access                 = "Deny"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_ranges = ["135", "139", "445", "1433", "1434", "3389"]
      source_address_prefix  = "Internet"
      destination_address_prefix = "*"
      description            = "Deny high-risk ports from Internet"
    }
  }

  enable_diagnostic_setting = true
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring-rg/providers/Microsoft.OperationalInsights/workspaces/main-law"

  tags = {
    Environment = "production"
    Security    = "high"
  }
}
```

## Security Considerations

### Predefined Rules

The module includes predefined security rules for common scenarios:

- **AllowHTTP/HTTPS**: Web traffic rules with Internet access
- **AllowSQL/MySQL/PostgreSQL**: Database rules restricted to VNet traffic
- **AllowSSH/RDP**: Management rules restricted to VNet traffic
- **DenyAllInbound**: Explicit deny rule for defense in depth

### Best Practices

1. **Least Privilege**: Always use the most restrictive rules necessary
2. **Source Restrictions**: Limit source address prefixes to specific networks
3. **Port Restrictions**: Specify exact ports rather than using wildcards
4. **Priority Management**: Use priority ranges (100-199 for allow, 200-299 for specific deny)
5. **Monitoring**: Enable diagnostic settings for security monitoring
6. **Management Locks**: Use management locks for critical security groups

### Rule Priority Guidelines

- **100-199**: Allow rules for required traffic
- **200-299**: Specific deny rules for known threats
- **300-399**: Management and monitoring rules
- **4000-4096**: Final deny rules and cleanup

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Network Security Group | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where the NSG will be created | `string` | n/a | yes |
| use_random_suffix | Whether to add a random suffix to the NSG name | `bool` | `false` | no |
| predefined_rules_enabled | List of predefined security rules to enable | `list(string)` | `[]` | no |
| custom_security_rules | Map of custom security rules to create | `map(object)` | `{}` | no |
| associated_subnet_ids | List of subnet IDs to associate with the NSG | `list(string)` | `[]` | no |
| associated_network_interface_ids | List of network interface IDs to associate | `list(string)` | `[]` | no |
| enable_diagnostic_setting | Whether to enable diagnostic settings | `bool` | `true` | no |
| log_analytics_workspace_id | Log Analytics workspace ID for diagnostics | `string` | `null` | no |
| diagnostic_log_categories | List of log categories to enable | `list(string)` | `["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]` | no |
| enable_management_lock | Whether to enable management lock | `bool` | `false` | no |
| management_lock_level | Level of management lock | `string` | `"CanNotDelete"` | no |
| management_lock_notes | Notes for the management lock | `string` | `"Managed by Terraform - do not delete"` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | ID of the Network Security Group |
| nsg_name | Name of the Network Security Group |
| nsg_resource_group_name | Resource group name of the NSG |
| nsg_location | Location of the Network Security Group |
| nsg_tags | Tags applied to the Network Security Group |
| security_rules | Map of security rules created |
| subnet_associations | Map of subnet associations |
| network_interface_associations | Map of network interface associations |
| diagnostic_setting_id | ID of the diagnostic setting |
| log_analytics_workspace_id | ID of the Log Analytics workspace |
| management_lock_id | ID of the management lock |
| predefined_rules_enabled | List of predefined rules enabled |
| custom_security_rules_count | Number of custom security rules created |
| total_security_rules_count | Total number of security rules created |
| random_suffix | Random suffix used in naming (if enabled) |

## Examples

See the [examples](../../examples/) directory for complete usage examples.

## License

This module is licensed under the Apache 2.0 License. See [LICENSE](../../LICENSE) for details. 