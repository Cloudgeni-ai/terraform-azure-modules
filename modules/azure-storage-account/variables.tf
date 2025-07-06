variable "name" {
  description = "The base name of the storage account (random suffix will be added for uniqueness)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.name))
    error_message = "Storage account name must be between 3-20 characters and can contain only lowercase letters and numbers."
  }
}

variable "name_override" {
  description = "Override the generated storage account name with a custom name (must be globally unique)"
  type        = string
  default     = null

  validation {
    condition     = var.name_override == null || can(regex("^[a-z0-9]{3,24}$", var.name_override))
    error_message = "Storage account name must be between 3-24 characters and can contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\.]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be between 1-90 characters and can contain alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "location" {
  description = "The Azure region where the storage account will be created"
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

variable "account_tier" {
  description = "The performance tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "The replication type of the storage account (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "The kind of storage account (BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2)"
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "access_tier" {
  description = "The access tier for the storage account (Hot, Cool)"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be either 'Hot' or 'Cool'."
  }
}

variable "enable_https_traffic_only" {
  description = "Whether to enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Minimum TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Whether to allow nested items to be public"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Whether to enable shared access key"
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "Whether to default to OAuth authentication"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether to enable public network access"
  type        = bool
  default     = true
}

variable "network_rules" {
  description = "Network rules for the storage account"
  type = object({
    default_action             = string
    bypass                     = optional(list(string), [])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.network_rules == null || contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "Network rules default action must be either 'Allow' or 'Deny'."
  }
}

variable "identity" {
  description = "Identity configuration for the storage account"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "blob_properties" {
  description = "Blob properties configuration"
  type = object({
    versioning_enabled            = optional(bool, false)
    change_feed_enabled           = optional(bool, false)
    change_feed_retention_in_days = optional(number, 7)
    default_service_version       = optional(string, "2020-06-12")
    last_access_time_enabled      = optional(bool, false)
    cors_rule = optional(object({
      allowed_origins    = list(string)
      allowed_methods    = list(string)
      allowed_headers    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    }), null)
    delete_retention_policy = optional(object({
      days = number
    }), null)
    container_delete_retention_policy = optional(object({
      days = number
    }), null)
  })
  default = null
}

variable "containers" {
  description = "List of storage containers to create"
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
    metadata              = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for container in var.containers : 
      contains(["blob", "container", "private"], container.container_access_type)
    ])
    error_message = "Container access type must be one of: blob, container, private."
  }
}

variable "private_endpoint" {
  description = "Private endpoint configuration"
  type = object({
    subnet_id           = string
    subresource_names   = list(string)
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }), null)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the storage account"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags are allowed per resource."
  }
}

variable "create_management_lock" {
  description = "Whether to create a management lock for the storage account"
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
  default     = "Storage account locked to prevent accidental deletion"
} 