# Module Development Guide

This guide provides detailed instructions for developing high-quality Terraform modules for Azure services.

## 📋 Module Requirements

### Core Requirements

1. **Security First**: All modules must implement Azure security best practices
2. **Production Ready**: Modules must be suitable for production environments
3. **Consistent**: Follow established patterns and conventions
4. **Well Documented**: Include comprehensive documentation and examples
5. **Validated**: All inputs must have proper validation rules

### Technical Requirements

- Terraform >= 1.0
- AzureRM Provider ~> 3.0
- Follow semantic versioning
- Include proper error handling

## 🏗️ Module Architecture

### Standard Structure

```
modules/azure-service-name/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables with validation
├── outputs.tf          # Output values
├── versions.tf         # Terraform and provider constraints
├── README.md           # Module documentation
└── examples/           # Usage examples
    ├── basic/
    ├── complete/
    └── advanced/
```

### File Descriptions

#### `main.tf`
- Contains all resource definitions
- Includes provider configuration
- Implements security defaults
- Uses consistent naming patterns

#### `variables.tf`
- All input variables with descriptions
- Proper type definitions
- Validation rules where appropriate
- Default values for optional parameters

#### `outputs.tf`
- All output values with descriptions
- Sensitive outputs marked appropriately
- Consistent naming patterns

#### `versions.tf`
- Terraform version constraints
- Provider version constraints
- Required providers

#### `README.md`
- Module description and features
- Usage examples
- Requirements and providers
- Inputs and outputs tables
- Security considerations

## 🔒 Security Standards

### Required Security Features

1. **Encryption**
   - Enable encryption at rest by default
   - Use latest TLS versions
   - Disable insecure protocols

2. **Network Security**
   - Support private endpoints
   - Enable network restrictions
   - Configure firewall rules

3. **Access Control**
   - Use managed identities
   - Implement RBAC
   - Follow least privilege principle

4. **Monitoring**
   - Enable diagnostic settings
   - Configure logging
   - Set up alerts where appropriate

### Security Code Examples

```hcl
# ✅ Good: Security defaults
resource "azurerm_storage_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # Security settings
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = var.shared_access_key_enabled
  default_to_oauth_authentication = true
  
  # Network security
  public_network_access_enabled = var.public_network_access_enabled
  
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action = "Deny"
      bypass         = ["AzureServices"]
      # ... other rules
    }
  }
}
```

## 📝 Variable Guidelines

### Variable Definitions

```hcl
variable "name" {
  description = "The name of the storage account"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3-24 characters and contain only lowercase letters and numbers."
  }
}

variable "location" {
  description = "The Azure region where the storage account will be created"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "centralus",
      "northeurope", "westeurope", "eastasia", "southeastasia"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags are allowed per resource."
  }
}
```

### Variable Best Practices

1. **Required vs Optional**: Minimize required variables
2. **Sensible Defaults**: Provide secure defaults
3. **Clear Descriptions**: Write helpful descriptions
4. **Validation Rules**: Add validation where appropriate
5. **Type Constraints**: Use specific types

## 📤 Output Guidelines

### Output Definitions

```hcl
output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "endpoints" {
  description = "Storage account endpoints"
  value = {
    blob  = azurerm_storage_account.this.primary_blob_endpoint
    queue = azurerm_storage_account.this.primary_queue_endpoint
    table = azurerm_storage_account.this.primary_table_endpoint
    file  = azurerm_storage_account.this.primary_file_endpoint
  }
}
```

### Output Best Practices

1. **Comprehensive**: Include all useful outputs
2. **Consistent Naming**: Use descriptive names
3. **Sensitive Data**: Mark sensitive outputs
4. **Complex Objects**: Group related outputs
5. **Clear Descriptions**: Write helpful descriptions

## 🏷️ Tagging Strategy

### Standard Tags

All resources should include these tags:

```hcl
tags = merge(
  var.tags,
  {
    "ManagedBy" = "Terraform"
    "Module"    = "azure-storage-account"
  }
)
```

### Recommended Tags

Encourage users to provide:
- `Environment` (e.g., "Production", "Development")
- `Project` (e.g., "MyApp")
- `Owner` (e.g., "team@company.com")
- `CostCenter` (e.g., "Engineering")

## 🧪 Testing Guidelines

### Module Testing

1. **Syntax Validation**
   ```bash
   terraform validate
   ```

2. **Plan Testing**
   ```bash
   terraform plan
   ```

3. **Example Testing**
   - Test all examples
   - Verify resource creation
   - Check outputs

### Integration Testing

1. **Real Azure Environment**
   - Create test subscription
   - Use test resource groups
   - Clean up after testing

2. **Security Testing**
   - Verify security defaults
   - Test network restrictions
   - Check access controls

## 📖 Documentation Standards

### README Template

```markdown
# Azure Service Name Module

Brief description of what the module does.

## Features

- ✅ Feature 1
- ✅ Feature 2
- ✅ Feature 3

## Usage

### Basic Usage

```hcl
module "service" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-service-name"
  
  name     = "example"
  location = "East US"
  
  tags = {
    Environment = "Production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the resource | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource |

## Security Considerations

- List security features
- Mention best practices
- Highlight important settings
```

### Documentation Best Practices

1. **Clear Examples**: Show real-world usage
2. **Complete Tables**: Include all inputs/outputs
3. **Security Notes**: Highlight security features
4. **Prerequisites**: List requirements clearly
5. **Troubleshooting**: Include common issues

## 🚀 Release Guidelines

### Version Management

1. **Semantic Versioning**: Use vX.Y.Z format
2. **Breaking Changes**: Increment major version
3. **New Features**: Increment minor version
4. **Bug Fixes**: Increment patch version

### Release Process

1. **Testing**: Comprehensive testing
2. **Documentation**: Update all documentation
3. **Changelog**: Document all changes
4. **Tagging**: Create Git tags
5. **Announcement**: Notify community

## 🔍 Common Patterns

### Resource Naming

```hcl
# Generate unique names when needed
resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "this" {
  name = "${var.name}${random_id.suffix.hex}"
  # ...
}
```

### Conditional Resources

```hcl
resource "azurerm_management_lock" "this" {
  count = var.create_management_lock ? 1 : 0
  
  name       = "${var.name}-lock"
  scope      = azurerm_storage_account.this.id
  lock_level = var.management_lock_level
}
```

### Dynamic Blocks

```hcl
dynamic "network_rules" {
  for_each = var.network_rules != null ? [var.network_rules] : []
  content {
    default_action = network_rules.value.default_action
    bypass         = network_rules.value.bypass
    ip_rules       = network_rules.value.ip_rules
  }
}
```

## ❓ FAQ

### Q: How do I handle resource naming conflicts?
A: Use random suffixes or provide name override options.

### Q: What if Azure provider changes?
A: Pin to compatible provider versions and update gradually.

### Q: How do I handle breaking changes?
A: Increment major version and document migration path.

## 📞 Support

For questions about module development:
- Open a [Discussion](https://github.com/Cloudgeni-ai/terraform-azure-modules/discussions)
- Review existing [Issues](https://github.com/Cloudgeni-ai/terraform-azure-modules/issues)
- Check the [Contributing Guide](../CONTRIBUTING.md)

---

**Happy Module Development!** 🎉 