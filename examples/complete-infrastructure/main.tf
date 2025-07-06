# Complete Azure Infrastructure Example
# This example demonstrates how to use multiple modules together to create a secure, production-ready infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Local values for common configuration
locals {
  project_name = "myproject"
  environment  = "production"
  location     = "East US"
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "infrastructure-team"
    CostCenter  = "engineering"
  }
}

# Generate random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Resource Group
module "resource_group" {
  source = "../../modules/azure-resource-group"
  
  name     = "${local.project_name}-${local.environment}-rg"
  location = local.location
  
  # Enable management lock for production
  create_management_lock = true
  management_lock_level  = "CanNotDelete"
  management_lock_notes  = "Critical production resource group"
  
  tags = local.common_tags
}

# Virtual Network with subnets
module "virtual_network" {
  source = "../../modules/azure-virtual-network"
  
  name                = "${local.project_name}-${local.environment}-vnet"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/16"]
  
  # DNS servers
  dns_servers = ["10.0.0.4", "10.0.0.5"]
  
  # Subnets with different configurations
  subnets = [
    {
      name           = "web-subnet"
      address_prefix = "10.0.1.0/24"
      create_nsg     = true
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    },
    {
      name           = "app-subnet"
      address_prefix = "10.0.2.0/24"
      create_nsg     = true
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
    },
    {
      name           = "data-subnet"
      address_prefix = "10.0.3.0/24"
      create_nsg     = true
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
    },
    {
      name           = "pe-subnet"
      address_prefix = "10.0.4.0/24"
      create_nsg     = true
      private_endpoint_network_policies_enabled = false
    }
  ]
  
  # Enable DDoS protection for production
  create_ddos_protection_plan = true
  
  tags = local.common_tags
}

# Storage Account for application data
module "storage_account" {
  source = "../../modules/azure-storage-account"
  
  name                = "${local.project_name}${local.environment}sa"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  
  # Performance and replication
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  
  # Security settings
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = true
  default_to_oauth_authentication   = true
  public_network_access_enabled     = false
  
  # Network rules - deny by default, allow specific subnets
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = []
    virtual_network_subnet_ids = [
      module.virtual_network.subnet_ids["web-subnet"],
      module.virtual_network.subnet_ids["app-subnet"],
      module.virtual_network.subnet_ids["data-subnet"]
    ]
  }
  
  # Identity for RBAC
  identity = {
    type = "SystemAssigned"
  }
  
  # Blob properties for compliance
  blob_properties = {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 30
    last_access_time_enabled      = true
    delete_retention_policy = {
      days = 30
    }
    container_delete_retention_policy = {
      days = 30
    }
  }
  
  # Storage containers
  containers = [
    {
      name                  = "app-data"
      container_access_type = "private"
      metadata = {
        purpose = "application-data"
      }
    },
    {
      name                  = "backups"
      container_access_type = "private"
      metadata = {
        purpose = "database-backups"
      }
    },
    {
      name                  = "logs"
      container_access_type = "private"
      metadata = {
        purpose = "application-logs"
      }
    }
  ]
  
  # Private endpoint for secure access
  private_endpoint = {
    subnet_id         = module.virtual_network.subnet_ids["pe-subnet"]
    subresource_names = ["blob"]
  }
  
  # Management lock for production
  create_management_lock = true
  management_lock_level  = "CanNotDelete"
  management_lock_notes  = "Critical production storage account"
  
  tags = local.common_tags
}

# Key Vault for secrets and keys
module "key_vault" {
  source = "../../modules/azure-key-vault"
  
  name                = "${local.project_name}-${local.environment}-kv-${random_id.suffix.hex}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  
  # Use premium SKU for production
  sku_name = "premium"
  
  # Security settings
  purge_protection_enabled        = true
  soft_delete_retention_days      = 30
  public_network_access_enabled   = false
  enable_rbac_authorization       = true
  
  # Azure service integrations
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  
  # Network access control
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [
      module.virtual_network.subnet_ids["web-subnet"],
      module.virtual_network.subnet_ids["app-subnet"],
      module.virtual_network.subnet_ids["data-subnet"]
    ]
  }
  
  # Application secrets
  secrets = {
    "database-connection-string" = {
      name         = "database-connection-string"
      value        = "Server=tcp:${local.project_name}-sql.database.windows.net,1433;Database=${local.project_name}db;Encrypt=true;Connection Timeout=30;"
      content_type = "connection-string"
    }
    "storage-account-key" = {
      name         = "storage-account-key"
      value        = module.storage_account.primary_access_key
      content_type = "access-key"
    }
    "api-key" = {
      name         = "external-api-key"
      value        = "placeholder-api-key-value"
      content_type = "api-key"
    }
  }
  
  # Encryption keys
  keys = {
    "app-encryption-key" = {
      name     = "app-encryption-key"
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
    }
    "signing-key" = {
      name     = "document-signing-key"
      key_type = "EC"
      curve    = "P-256"
      key_opts = ["sign", "verify"]
    }
  }
  
  # Private endpoint for secure access
  private_endpoint = {
    subnet_id = module.virtual_network.subnet_ids["pe-subnet"]
  }
  
  # Management lock for production
  create_management_lock = true
  management_lock_level  = "CanNotDelete"
  management_lock_notes  = "Critical production Key Vault"
  
  tags = local.common_tags
} 