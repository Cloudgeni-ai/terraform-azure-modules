# Terraform Azure Modules 🚀

![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)

🌟 **Collection of secure, well-designed, and reusable Terraform modules for Microsoft Azure** 🌟

Inspired by the excellent [terraform-aws-modules](https://github.com/terraform-aws-modules) organization, this project provides a comprehensive collection of community-maintained Terraform modules for Azure services. Each module follows security best practices, implements proper tagging, and includes comprehensive documentation.

## 🎯 Project Goals

- **Security First**: All modules implement Azure security best practices by default
- **Production Ready**: Modules are battle-tested and suitable for production environments
- **Consistent Structure**: Standardized module structure for easy adoption and maintenance
- **Community Driven**: Open-source project welcoming contributions from the community
- **Comprehensive Documentation**: Each module includes detailed documentation and examples

## 🏗️ Available Modules

### Core Infrastructure
| Module | Description | Status |
|--------|-------------|--------|
| [azure-resource-group](./modules/azure-resource-group) | Create and manage Azure Resource Groups | ✅ Available |
| [azure-virtual-network](./modules/azure-virtual-network) | Create secure Virtual Networks with subnets | ✅ Available |
| [azure-network-security-group](./modules/azure-network-security-group) | Network Security Groups with predefined rules | ✅ Available |
| [azure-key-vault](./modules/azure-key-vault) | Secure Key Vault with access policies | ✅ Available |
| [azure-storage-account](./modules/azure-storage-account) | Secure Storage Account with encryption | ✅ Available |

### Compute Services
| Module | Description | Status |
|--------|-------------|--------|
| [azure-virtual-machine](./modules/azure-virtual-machine) | Virtual Machines with security hardening | 🚧 In Progress |
| [azure-vmss](./modules/azure-vmss) | Virtual Machine Scale Sets | 📋 Planned |
| [azure-aks](./modules/azure-aks) | Azure Kubernetes Service | 📋 Planned |
| [azure-container-instances](./modules/azure-container-instances) | Container Instances | 📋 Planned |

### Database Services
| Module | Description | Status |
|--------|-------------|--------|
| [azure-sql-database](./modules/azure-sql-database) | SQL Database with security features | 📋 Planned |
| [azure-postgresql](./modules/azure-postgresql) | PostgreSQL Flexible Server | 📋 Planned |
| [azure-mysql](./modules/azure-mysql) | MySQL Flexible Server | 📋 Planned |
| [azure-cosmos-db](./modules/azure-cosmos-db) | Cosmos DB with encryption | 📋 Planned |

### Security & Identity
| Module | Description | Status |
|--------|-------------|--------|
| [azure-rbac](./modules/azure-rbac) | Role-Based Access Control | 📋 Planned |
| [azure-managed-identity](./modules/azure-managed-identity) | Managed Identity assignments | 📋 Planned |
| [azure-private-endpoint](./modules/azure-private-endpoint) | Private Endpoints for services | 📋 Planned |

### Monitoring & Logging
| Module | Description | Status |
|--------|-------------|--------|
| [azure-log-analytics](./modules/azure-log-analytics) | Log Analytics Workspace | 📋 Planned |
| [azure-application-insights](./modules/azure-application-insights) | Application Insights | 📋 Planned |

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) 
- Azure subscription and appropriate permissions

### Using a Module

```hcl
# Example: Creating a Resource Group
module "resource_group" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-resource-group"
  
  name     = "my-rg"
  location = "East US"
  
  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}

# Example: Creating a Virtual Network
module "virtual_network" {
  source = "github.com/Cloudgeni-ai/terraform-azure-modules//modules/azure-virtual-network"
  
  name                = "my-vnet"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  
  address_space = ["10.0.0.0/16"]
  
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

## 📦 Module Structure

Each module follows this standardized structure:

```
modules/azure-service-name/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── versions.tf         # Terraform and provider version constraints
├── README.md           # Module documentation
└── examples/           # Usage examples
    ├── basic/
    ├── complete/
    └── advanced/
```

## 🔒 Security Features

All modules implement Azure security best practices:

- **Encryption**: Data encryption at rest and in transit by default
- **Network Security**: Private endpoints and network restrictions
- **Identity**: Managed identities where applicable
- **Monitoring**: Diagnostic settings and logging enabled
- **Access Control**: Least privilege access patterns
- **Compliance**: Alignment with Azure Security Benchmark

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes following our [module standards](docs/module-standards.md)
4. Add tests and documentation
5. Submit a pull request

## 📚 Documentation

- [Module Development Guide](docs/module-development.md)
- [Security Guidelines](docs/security-guidelines.md)
- [Testing Strategy](docs/testing.md)
- [Release Process](docs/releases.md)

## 🆘 Support

- 🐛 [Report Issues](https://github.com/Cloudgeni-ai/terraform-azure-modules/issues)
- 💬 [Discussions](https://github.com/Cloudgeni-ai/terraform-azure-modules/discussions)
- 📖 [Documentation](https://github.com/Cloudgeni-ai/terraform-azure-modules/tree/main/docs)

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Cloudgeni-ai/terraform-azure-modules&type=Date)](https://star-history.com/#Cloudgeni-ai/terraform-azure-modules&Date)

## 🙏 Acknowledgments

- Inspired by the excellent [terraform-aws-modules](https://github.com/terraform-aws-modules) project
- Thanks to all contributors who help make this project better
- Special thanks to the Azure community for feedback and suggestions

---

**Made with ❤️ by the Cloudgeni team and open-source community**