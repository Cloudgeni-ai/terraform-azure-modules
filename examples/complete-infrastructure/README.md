# Complete Azure Infrastructure Example

This example demonstrates how to use multiple Azure Terraform modules together to create a secure, production-ready infrastructure.

## Architecture

This example creates:

- **Resource Group** with management lock
- **Virtual Network** with multiple subnets and DDoS protection
- **Storage Account** with private endpoints and network restrictions
- **Key Vault** with secrets, keys, and private endpoints

## Features Demonstrated

### Security Best Practices
- ✅ Private endpoints for all services
- ✅ Network ACLs with deny-by-default policies
- ✅ RBAC authorization for Key Vault
- ✅ Management locks on critical resources
- ✅ TLS 1.2+ enforcement
- ✅ Blob versioning and soft delete
- ✅ DDoS protection for VNet

### Infrastructure Design
- ✅ Segregated subnets for different tiers
- ✅ Service endpoints for secure access
- ✅ Centralized secrets management
- ✅ Comprehensive tagging strategy
- ✅ GRS replication for storage

## Prerequisites

1. **Azure CLI** installed and authenticated
2. **Terraform** >= 1.0 installed
3. **Azure subscription** with appropriate permissions
4. **Resource providers** registered:
   - Microsoft.Network
   - Microsoft.Storage
   - Microsoft.KeyVault

## Usage

1. **Clone the repository**:
   ```bash
git clone https://github.com/Cloudgeni-ai/terraform-azure-modules.git
   cd terraform-azure-modules/examples/complete-infrastructure
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Clean up** (when done):
   ```bash
   terraform destroy
   ```

## Configuration

### Variables

You can customize the deployment by modifying the local values in `main.tf`:

```hcl
locals {
  project_name = "myproject"    # Change to your project name
  environment  = "production"   # Change to your environment
  location     = "East US"      # Change to your preferred region
}
```

### Network Configuration

The example creates a VNet with the following subnets:

| Subnet | CIDR | Purpose | NSG | Service Endpoints |
|--------|------|---------|-----|-------------------|
| web-subnet | 10.0.1.0/24 | Web tier | ✅ | Storage, KeyVault |
| app-subnet | 10.0.2.0/24 | Application tier | ✅ | Storage, KeyVault, SQL |
| data-subnet | 10.0.3.0/24 | Data tier | ✅ | Storage, KeyVault, SQL |
| pe-subnet | 10.0.4.0/24 | Private endpoints | ✅ | - |

### Storage Configuration

The storage account includes:
- **Containers**: app-data, backups, logs
- **Security**: HTTPS only, TLS 1.2+, no public access
- **Features**: Versioning, change feed, soft delete
- **Access**: Private endpoint + service endpoints

### Key Vault Configuration

The Key Vault includes:
- **Secrets**: Database connection string, storage keys, API keys
- **Keys**: RSA encryption key, EC signing key
- **Security**: RBAC, private endpoint, network ACLs
- **Features**: Purge protection, soft delete (30 days)

## Outputs

After deployment, you'll get information about:

- Resource IDs and names
- Network configuration
- Storage endpoints
- Key Vault URI
- Security features status

## Security Considerations

### Network Security
- All services use private endpoints
- Network ACLs deny public access by default
- Service endpoints provide secure Azure backbone access
- NSGs protect each subnet

### Access Control
- RBAC used for all services
- Managed identities where possible
- Least privilege access patterns
- Management locks prevent accidental deletion

### Data Protection
- Storage encryption at rest and in transit
- Key Vault for centralized secrets management
- Blob versioning and soft delete protection
- GRS replication for disaster recovery

### Monitoring & Compliance
- Consistent tagging for cost tracking
- Audit logging capabilities
- Change tracking enabled
- Retention policies configured

## Cost Considerations

This example creates the following billable resources:

- **Resource Group**: Free
- **Virtual Network**: Free (data transfer charges apply)
- **DDoS Protection**: ~$2,944/month per protected VNet
- **Storage Account**: Based on storage and transactions
- **Key Vault**: $0.03 per 10,000 operations
- **Private Endpoints**: $0.01/hour per endpoint

> **Note**: DDoS protection has significant cost. Consider disabling for non-production environments.

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Ensure you have Contributor access to the subscription
   - Register required resource providers

2. **Naming Conflicts**
   - Key Vault names must be globally unique
   - Storage account names must be globally unique
   - Modify the `project_name` local value

3. **Network Access Issues**
   - Private endpoints may take time to propagate
   - DNS resolution requires private DNS zones

### Getting Help

- Check the [Contributing Guide](../../CONTRIBUTING.md)
- Open an [Issue](https://github.com/Cloudgeni-ai/terraform-azure-modules/issues)
- Review individual module documentation

## Next Steps

After deploying this example, consider:

1. **Adding more modules** (SQL Database, App Service, etc.)
2. **Implementing CI/CD** pipelines
3. **Setting up monitoring** with Log Analytics
4. **Configuring backup** strategies
5. **Implementing disaster recovery**

## Contributing

Improvements to this example are welcome! Please see the [Contributing Guide](../../CONTRIBUTING.md) for details.

---

**This example demonstrates production-ready Azure infrastructure using secure, reusable Terraform modules.** 