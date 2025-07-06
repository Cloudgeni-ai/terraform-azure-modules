# Azure Resource Group Module

This module creates an Azure Resource Group with optional management lock for security.

## Features

- ✅ Creates Azure Resource Group with proper naming validation
- ✅ Configurable tags with automatic module tagging
- ✅ Optional management lock to prevent accidental deletion
- ✅ Lifecycle management for safe resource replacement
- ✅ Comprehensive input validation

## Usage

### Basic Usage

```hcl
module "resource_group" {
  source = "github.com/your-org/terraform-azure-modules//modules/azure-resource-group"

  name     = "my-rg"
  location = "East US"

  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

### With Management Lock

```hcl
module "resource_group" {
  source = "github.com/your-org/terraform-azure-modules//modules/azure-resource-group"

  name     = "my-rg"
  location = "East US"

  create_management_lock = true
  management_lock_level  = "CanNotDelete"
  management_lock_notes  = "Critical production resource group"

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
| name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region where the resource group will be created | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource group | `map(string)` | `{}` | no |
| create_management_lock | Whether to create a management lock for the resource group | `bool` | `false` | no |
| management_lock_level | The level of the management lock (CanNotDelete or ReadOnly) | `string` | `"CanNotDelete"` | no |
| management_lock_notes | Notes for the management lock | `string` | `"Resource group locked to prevent accidental deletion"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource group |
| name | The name of the resource group |
| location | The location of the resource group |
| tags | The tags assigned to the resource group |
| management_lock_id | The ID of the management lock (if created) |

## Examples

See the [examples](./examples) directory for complete usage examples.

## Security Considerations

- Resource group names are validated to ensure they meet Azure naming requirements
- Management locks can be enabled to prevent accidental deletion
- Tags are automatically applied to track module usage
- Maximum tag limit (50) is enforced

## Contributing

Please see the [Contributing Guide](../../CONTRIBUTING.md) for information on how to contribute to this module. 