variable "name" {
  description = "The name of the resource group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\.]{1,90}$", var.name))
    error_message = "Resource group name must be between 1-90 characters and can contain alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "location" {
  description = "The Azure region where the resource group will be created"
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

variable "tags" {
  description = "A mapping of tags to assign to the resource group"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags are allowed per resource group."
  }
}

variable "create_management_lock" {
  description = "Whether to create a management lock for the resource group"
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
  default     = "Resource group locked to prevent accidental deletion"
} 