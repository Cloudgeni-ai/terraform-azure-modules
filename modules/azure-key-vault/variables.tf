variable "name" {
  description = "The name of the Key Vault"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "Key Vault name must be between 3-24 characters and can contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the Key Vault will be created"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus", "westcentralus",
      "canadacentral", "canadaeast", "brazilsouth", "brazilsoutheast",
      "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "francesouth", "germanywestcentral", "norwayeast", "switzerlandnorth",
      "eastasia", "southeastasia", "japaneast", "japanwest", "koreacentral", "koreasouth", "australiaeast", "australiasoutheast", "centralindia", "southindia", "westindia",
      "southafricanorth", "uaenorth"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\.]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be between 1-90 characters and can contain alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "sku_name" {
  description = "The SKU name of the Key Vault (standard or premium)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_deployment" {
  description = "Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Whether to use RBAC for authorization instead of access policies"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for this Key Vault"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained after soft-delete"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this Key Vault"
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "Network access rules for the Key Vault"
  type = object({
    default_action             = string
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.network_acls == null || contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "Network ACLs default action must be either 'Allow' or 'Deny'."
  }
}

variable "access_policies" {
  description = "List of access policies for the Key Vault (used when RBAC is disabled)"
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default = []
}

variable "secrets" {
  description = "Map of secrets to create in the Key Vault"
  type = map(object({
    name            = string
    value           = string
    content_type    = optional(string)
    not_before_date = optional(string)
    expiration_date = optional(string)
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "keys" {
  description = "Map of keys to create in the Key Vault"
  type = map(object({
    name            = string
    key_type        = string
    key_size        = optional(number)
    curve           = optional(string)
    key_opts        = list(string)
    not_before_date = optional(string)
    expiration_date = optional(string)
    tags            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for key in var.keys : 
      contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], key.key_type)
    ])
    error_message = "Key type must be one of: EC, EC-HSM, RSA, RSA-HSM."
  }
}

variable "private_endpoint" {
  description = "Private endpoint configuration for the Key Vault"
  type = object({
    subnet_id = string
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }), null)
  })
  default = null
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for the Key Vault"
  type = object({
    log_analytics_workspace_id = string
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the Key Vault"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags are allowed per resource."
  }
}

variable "create_management_lock" {
  description = "Whether to create a management lock for the Key Vault"
  type        = bool
  default     = false
}

variable "management_lock_level" {
  description = "The level of the management lock (CanNotDelete or ReadOnly)"
  type        = string
  default     = "CanNotDelete"

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.management_lock_level)
    error_message = "Management lock level must be either 'CanNotDelete' or 'ReadOnly'."
  }
}

variable "management_lock_notes" {
  description = "Notes for the management lock"
  type        = string
  default     = "Key Vault locked to prevent accidental deletion"
} 