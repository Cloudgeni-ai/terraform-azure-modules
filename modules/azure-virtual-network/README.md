# Azure Virtual Network Module

This module creates an Azure Virtual Network with subnets, optional network security groups, and DDoS protection.

## Features

- ✅ Creates Azure Virtual Network with configurable address space
- ✅ Multiple subnet support with flexible configuration
- ✅ Optional Network Security Groups per subnet
- ✅ Service endpoints and subnet delegation support
- ✅ Optional DDoS protection plan
- ✅ Private endpoint and private link service policies
- ✅ Comprehensive validation and security defaults

## Usage

### Basic Usage

```hcl
module "virtual_network" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-virtual-network"

  name                = "my-vnet"
  location            = "East US"
  resource_group_name = "my-rg"
  address_space       = ["10.0.0.0/16"]

  subnets = [
    {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
    },
    {
      name           = "subnet2"
      address_prefix = "10.0.2.0/24"
    }
  ]

  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

### Advanced Usage with NSGs and Service Endpoints

```hcl
module "virtual_network" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-virtual-network"

  name                = "my-vnet"
  location            = "East US"
  resource_group_name = "my-rg"
  address_space       = ["10.0.0.0/16"]

  dns_servers = ["8.8.8.8", "8.8.4.4"]

  subnets = [
    {
      name           = "web-subnet"
      address_prefix = "10.0.1.0/24"
      create_nsg     = true
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    },
    {
      name           = "app-subnet"
      address_prefix = "10.0.2.0/24"
      create_nsg     = true
      private_endpoint_network_policies_enabled = false
    },
    {
      name           = "db-subnet"
      address_prefix = "10.0.3.0/24"
      create_nsg     = true
      delegation = [
        {
          name = "sql-delegation"
          service_delegation = {
            name    = "Microsoft.Sql/managedInstances"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
  ]

  create_ddos_protection_plan = true

  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the virtual network | `string` | n/a | yes |
| location | The Azure region where the virtual network will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the virtual network | `string` | n/a | yes |
| address_space | The address space that is used by the virtual network | `list(string)` | n/a | yes |
| dns_servers | List of DNS servers to use for the virtual network | `list(string)` | `[]` | no |
| subnets | List of subnets to create in the virtual network | `list(object)` | `[]` | no |
| tags | A mapping of tags to assign to the virtual network | `map(string)` | `{}` | no |
| create_ddos_protection_plan | Whether to create a DDoS protection plan and associate it with the virtual network | `bool` | `false` | no |

### Subnet Object Structure

```hcl
{
  name           = string
  address_prefix = string
  service_endpoints = optional(list(string), [])
  delegation = optional(list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })), [])
  private_endpoint_network_policies_enabled     = optional(bool, true)
  private_link_service_network_policies_enabled = optional(bool, true)
  create_nsg                                     = optional(bool, false)
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual network |
| name | The name of the virtual network |
| location | The location of the virtual network |
| resource_group_name | The name of the resource group in which the virtual network is created |
| address_space | The address space of the virtual network |
| dns_servers | The DNS servers of the virtual network |
| subnets | Map of subnet names to their configurations |
| subnet_ids | Map of subnet names to their IDs |
| network_security_groups | Map of subnet names to their NSG IDs (if created) |
| ddos_protection_plan_id | The ID of the DDoS protection plan (if created) |
| tags | The tags assigned to the virtual network |

## Examples

See the [examples](./examples) directory for complete usage examples.

## Security Considerations

- Network Security Groups are created with default deny-all rules for enhanced security
- DDoS protection can be enabled for production environments
- Service endpoints enable secure access to Azure services
- Private endpoint policies can be configured per subnet
- Subnet delegation supports Azure service integration

## Service Endpoints

Supported service endpoints:
- Microsoft.Storage
- Microsoft.Sql
- Microsoft.AzureActiveDirectory
- Microsoft.AzureCosmosDB
- Microsoft.KeyVault
- Microsoft.ServiceBus
- Microsoft.EventHub
- Microsoft.Web

## Contributing

Please see the [Contributing Guide](../../CONTRIBUTING.md) for information on how to contribute to this module. 