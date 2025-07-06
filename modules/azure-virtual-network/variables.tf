variable "name" {
  description = "The name of the virtual network"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\.]{1,80}$", var.name))
    error_message = "Virtual network name must be between 1-80 characters and can contain alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "location" {
  description = "The Azure region where the virtual network will be created"
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
  description = "The name of the resource group in which to create the virtual network"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\.]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be between 1-90 characters and can contain alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "address_space" {
  description = "The address space that is used by the virtual network"
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be provided."
  }
}

variable "dns_servers" {
  description = "List of DNS servers to use for the virtual network"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.dns_servers) <= 20
    error_message = "Maximum of 20 DNS servers are allowed."
  }
}

variable "subnets" {
  description = "List of subnets to create in the virtual network"
  type = list(object({
    name           = string
    address_prefix = string
    service_endpoints = optional(list(string), [])
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    create_nsg                                     = optional(bool, false)
  }))
  default = []

  validation {
    condition     = length(var.subnets) <= 3000
    error_message = "Maximum of 3000 subnets are allowed per virtual network."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the virtual network"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags are allowed per resource."
  }
}

variable "create_ddos_protection_plan" {
  description = "Whether to create a DDoS protection plan and associate it with the virtual network"
  type        = bool
  default     = false
} 