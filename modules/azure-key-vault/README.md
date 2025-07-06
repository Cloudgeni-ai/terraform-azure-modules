# Azure Key Vault Module

This module creates an Azure Key Vault with comprehensive security features, secrets management, and optional private endpoints.

## Features

- ✅ Creates Azure Key Vault with configurable SKU
- ✅ RBAC authorization support (default) or access policies
- ✅ Network access control with ACLs
- ✅ Private endpoint support
- ✅ Secrets and keys management
- ✅ Diagnostic settings and monitoring
- ✅ Purge protection and soft delete
- ✅ Management lock for critical resources

## Usage

### Basic Usage

```hcl
module "key_vault" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-key-vault"

  name                = "my-kv"
  location            = "East US"
  resource_group_name = "my-rg"

  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

### Advanced Usage with Secrets and Keys

```hcl
module "key_vault" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-key-vault"

  name                = "my-kv"
  location            = "East US"
  resource_group_name = "my-rg"
  sku_name            = "premium"

  # Security settings
  purge_protection_enabled        = true
  soft_delete_retention_days      = 30
  public_network_access_enabled   = false
  enable_rbac_authorization       = true

  # Network access control
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [
      "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet1"
    ]
  }

  # Secrets
  secrets = {
    "database-password" = {
      name  = "database-password"
      value = "SuperSecretPassword123!"
      content_type = "password"
    }
    "api-key" = {
      name  = "api-key"
      value = "abcd1234-5678-90ef-ghij-klmnopqrstuv"
      content_type = "api-key"
    }
  }

  # Keys
  keys = {
    "encryption-key" = {
      name     = "encryption-key"
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    }
    "signing-key" = {
      name     = "signing-key"
      key_type = "EC"
      curve    = "P-256"
      key_opts = ["sign", "verify"]
    }
  }

  # Private endpoint
  private_endpoint = {
    subnet_id = "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"
    private_dns_zone_group = {
      name = "default"
      private_dns_zone_ids = [
        "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
      ]
    }
  }

  # Diagnostic settings
  diagnostic_settings = {
    log_analytics_workspace_id = "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law"
  }

  # Management lock
  create_management_lock = true
  management_lock_level  = "CanNotDelete"

  tags = {
    Environment = "Production"
    Project     = "MyProject"
    Critical    = "true"
  }
}
```

### Usage with Access Policies (Legacy)

```hcl
module "key_vault" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-key-vault"

  name                = "my-kv"
  location            = "East US"
  resource_group_name = "my-rg"

  # Disable RBAC to use access policies
  enable_rbac_authorization = false

  # Access policies
  access_policies = [
    {
      object_id = "12345678-1234-1234-1234-123456789012"
      key_permissions = ["Get", "List", "Create", "Update", "Delete"]
      secret_permissions = ["Get", "List", "Set", "Delete"]
      certificate_permissions = ["Get", "List", "Create", "Update", "Delete"]
    }
  ]

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
| name | The name of the Key Vault | `string` | n/a | yes |
| location | The Azure region where the Key Vault will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Key Vault | `string` | n/a | yes |
| sku_name | The SKU name of the Key Vault (standard or premium) | `string` | `"standard"` | no |
| enabled_for_deployment | Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault | `bool` | `false` | no |
| enabled_for_disk_encryption | Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys | `bool` | `false` | no |
| enabled_for_template_deployment | Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault | `bool` | `false` | no |
| enable_rbac_authorization | Whether to use RBAC for authorization instead of access policies | `bool` | `true` | no |
| purge_protection_enabled | Whether purge protection is enabled for this Key Vault | `bool` | `true` | no |
| soft_delete_retention_days | The number of days that items should be retained after soft-delete | `number` | `7` | no |
| public_network_access_enabled | Whether public network access is allowed for this Key Vault | `bool` | `true` | no |
| network_acls | Network access rules for the Key Vault | `object` | `null` | no |
| access_policies | List of access policies for the Key Vault (used when RBAC is disabled) | `list(object)` | `[]` | no |
| secrets | Map of secrets to create in the Key Vault | `map(object)` | `{}` | no |
| keys | Map of keys to create in the Key Vault | `map(object)` | `{}` | no |
| private_endpoint | Private endpoint configuration for the Key Vault | `object` | `null` | no |
| diagnostic_settings | Diagnostic settings for the Key Vault | `object` | `null` | no |
| tags | A mapping of tags to assign to the Key Vault | `map(string)` | `{}` | no |
| create_management_lock | Whether to create a management lock for the Key Vault | `bool` | `false` | no |
| management_lock_level | The level of the management lock (CanNotDelete or ReadOnly) | `string` | `"CanNotDelete"` | no |
| management_lock_notes | Notes for the management lock | `string` | `"Key Vault locked to prevent accidental deletion"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Key Vault |
| name | The name of the Key Vault |
| location | The location of the Key Vault |
| resource_group_name | The name of the resource group in which the Key Vault is created |
| vault_uri | The URI of the Key Vault |
| tenant_id | The tenant ID of the Key Vault |
| sku_name | The SKU name of the Key Vault |
| access_policy | The access policies of the Key Vault |
| secrets | Map of secrets created in the Key Vault |
| keys | Map of keys created in the Key Vault |
| private_endpoint_id | The ID of the private endpoint (if created) |
| diagnostic_setting_id | The ID of the diagnostic setting (if created) |
| management_lock_id | The ID of the management lock (if created) |
| tags | The tags assigned to the Key Vault |

## Examples

See the [examples](./examples) directory for complete usage examples.

## Security Considerations

- **RBAC Authorization**: Uses RBAC by default for better security and management
- **Network Isolation**: Supports private endpoints and network ACLs
- **Purge Protection**: Enabled by default to prevent accidental permanent deletion
- **Soft Delete**: Configurable retention period for deleted items
- **Diagnostic Logging**: Supports audit logging to Log Analytics
- **Management Lock**: Optional lock to prevent accidental deletion
- **Access Policies**: Fallback to traditional access policies when needed

## Key Features

### Supported Key Types
- RSA (2048, 3072, 4096 bits)
- EC (P-256, P-384, P-521, P-256K curves)
- RSA-HSM (2048, 3072, 4096 bits)
- EC-HSM (P-256, P-384, P-521, P-256K curves)

### Supported Operations
- Key: decrypt, encrypt, sign, unwrapKey, verify, wrapKey
- Secret: get, list, set, delete, backup, restore, recover, purge
- Certificate: get, list, create, update, delete, backup, restore, recover, purge, managecontacts, manageissuers, getissuers, listissuers, setissuers, deleteissuers

### Network Access Control
- Public network access control
- IP-based access rules
- Virtual network subnet restrictions
- Private endpoint support

## Contributing

Please see the [Contributing Guide](../../CONTRIBUTING.md) for information on how to contribute to this module. 