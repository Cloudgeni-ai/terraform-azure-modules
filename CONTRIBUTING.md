# Contributing to Terraform Azure Modules

Welcome! We're excited that you're interested in contributing to the Terraform Azure Modules project. This guide will help you understand how to contribute effectively.

## 🎯 Project Vision

Our goal is to provide secure, well-designed, and reusable Terraform modules for Azure that follow best practices and are production-ready. Every contribution should align with this vision.

## 🤝 Ways to Contribute

### 1. **Module Development**
- Create new modules for Azure services
- Enhance existing modules with new features
- Improve security posture of existing modules

### 2. **Documentation**
- Improve module documentation
- Add usage examples
- Write guides and best practices

### 3. **Testing**
- Add or improve tests
- Test modules in different scenarios
- Report bugs and issues

### 4. **Community Support**
- Help answer questions in Issues and Discussions
- Review pull requests
- Share your experience and use cases

## 📋 Before You Start

### Prerequisites

1. **Required Tools**
   - [Terraform](https://www.terraform.io/downloads.html) >= 1.0
   - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   - [Git](https://git-scm.com/downloads)
   - [Make](https://www.gnu.org/software/make/) (optional, for automation)

2. **Azure Access**
   - Azure subscription for testing
   - Appropriate permissions to create resources

3. **Knowledge**
   - Basic understanding of Terraform
   - Familiarity with Azure services
   - Understanding of security best practices

## 🏗️ Module Development Standards

### Module Structure

Each module must follow this standardized structure:

```
modules/azure-service-name/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables with validation
├── outputs.tf          # Output values
├── versions.tf         # Terraform and provider constraints
├── README.md           # Module documentation
└── examples/           # Usage examples
    ├── basic/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── complete/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── advanced/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Naming Conventions

- **Module Names**: `azure-service-name` (e.g., `azure-storage-account`)
- **Resource Names**: Use descriptive names with the service type
- **Variables**: Use snake_case
- **Outputs**: Use snake_case
- **Files**: Use snake_case

### Code Standards

#### 1. **Resource Definitions**
```hcl
# ✅ Good
resource "azurerm_storage_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # Always include security settings
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  
  # Consistent tagging
  tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "azure-storage-account"
    }
  )
}
```

#### 2. **Variable Definitions**
```hcl
# ✅ Good
variable "name" {
  description = "The name of the storage account"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3-24 characters and contain only lowercase letters and numbers."
  }
}
```

#### 3. **Output Definitions**
```hcl
# ✅ Good
output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}
```

### Security Requirements

All modules must implement these security standards:

1. **Encryption**: Enable encryption at rest and in transit by default
2. **Network Security**: Use private endpoints when possible
3. **Access Control**: Implement least privilege access
4. **Monitoring**: Enable diagnostic settings
5. **Validation**: Validate all inputs with appropriate constraints

### Documentation Requirements

Each module must include:

1. **README.md** with:
   - Clear description and features
   - Usage examples (basic, complete, advanced)
   - Requirements and providers table
   - Inputs and outputs tables
   - Security considerations

2. **Examples** demonstrating:
   - Basic usage with minimal configuration
   - Complete usage with all features
   - Advanced usage with complex scenarios

## 🔄 Development Workflow

### 1. **Fork and Clone**
```bash
# Fork the repository on GitHub
git clone https://github.com/YOUR-USERNAME/terraform-azure-modules.git
cd terraform-azure-modules
```

### 2. **Create a Branch**
```bash
git checkout -b feature/azure-new-service
```

### 3. **Develop Your Module**
- Follow the module structure and standards
- Add comprehensive validation
- Include security best practices
- Write clear documentation

### 4. **Test Your Module**
```bash
# Navigate to your module
cd modules/azure-your-service

# Initialize Terraform
terraform init

# Validate syntax
terraform validate

# Plan (with test variables)
terraform plan
```

### 5. **Create Examples**
Create at least these three examples:
- `examples/basic/` - Minimal configuration
- `examples/complete/` - Full feature demonstration
- `examples/advanced/` - Complex real-world scenario

### 6. **Submit Pull Request**
- Push your branch to your fork
- Create a Pull Request with:
  - Clear title and description
  - Reference to any related issues
  - Screenshots if applicable
  - Checklist completion

## ✅ Pull Request Checklist

Before submitting a pull request, ensure:

### Code Quality
- [ ] Code follows the established patterns and conventions
- [ ] All variables have proper validation
- [ ] Security best practices are implemented
- [ ] Resources are properly tagged
- [ ] Sensitive outputs are marked as sensitive

### Documentation
- [ ] README.md is complete and accurate
- [ ] All inputs and outputs are documented
- [ ] Examples are provided (basic, complete, advanced)
- [ ] Security considerations are documented

### Testing
- [ ] Module passes `terraform validate`
- [ ] Module passes `terraform plan`
- [ ] Examples have been tested
- [ ] No breaking changes to existing functionality

### Compliance
- [ ] Module name follows naming conventions
- [ ] Directory structure is correct
- [ ] Version constraints are appropriate
- [ ] License compatibility is maintained

## 🚀 Release Process

1. **Version Tagging**: We use semantic versioning (vX.Y.Z)
2. **Release Notes**: Detailed changelog with breaking changes
3. **Documentation**: Updated README and examples
4. **Testing**: Comprehensive testing in multiple environments

## 📞 Getting Help

- **Questions**: Open a [Discussion](https://github.com/your-org/terraform-azure-modules/discussions)
- **Bugs**: Report in [Issues](https://github.com/your-org/terraform-azure-modules/issues)
- **Feature Requests**: Open an [Issue](https://github.com/your-org/terraform-azure-modules/issues) with the enhancement label

## 🏆 Recognition

Contributors are recognized in:
- Project README
- Release notes
- Module documentation
- Community discussions

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the Apache 2.0 License.

## 🙏 Thank You

Thank you for contributing to the Terraform Azure Modules project! Your contributions help make Azure infrastructure more secure and accessible for everyone.

---

**Happy Contributing!** 🎉 