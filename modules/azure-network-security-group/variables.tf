variable "name" {
  description = "Name of the Network Security Group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-._])*[a-zA-Z0-9]$", var.name))
    error_message = "NSG name must start and end with alphanumeric characters and can contain hyphens, periods, and underscores."
  }

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "NSG name must be between 1 and 80 characters long."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the NSG will be created"
  type        = string
}

variable "use_random_suffix" {
  description = "Whether to add a random suffix to the NSG name for uniqueness"
  type        = bool
  default     = false
}

variable "predefined_rules_enabled" {
  description = "List of predefined security rules to enable"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for rule in var.predefined_rules_enabled : contains([
        "AllowHTTP", "AllowHTTPS", "AllowSQL", "AllowMySQL", "AllowPostgreSQL",
        "AllowSSH", "AllowRDP", "DenyAllInbound"
      ], rule)
    ])
    error_message = "Predefined rules must be one of: AllowHTTP, AllowHTTPS, AllowSQL, AllowMySQL, AllowPostgreSQL, AllowSSH, AllowRDP, DenyAllInbound."
  }
}

variable "custom_security_rules" {
  description = "Map of custom security rules to create"
  type = map(object({
    name                                       = string
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
    description                                = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.custom_security_rules) : rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Security rule priority must be between 100 and 4096."
  }

  validation {
    condition = alltrue([
      for rule in values(var.custom_security_rules) : contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "Security rule direction must be 'Inbound' or 'Outbound'."
  }

  validation {
    condition = alltrue([
      for rule in values(var.custom_security_rules) : contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "Security rule access must be 'Allow' or 'Deny'."
  }

  validation {
    condition = alltrue([
      for rule in values(var.custom_security_rules) : contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol)
    ])
    error_message = "Security rule protocol must be 'Tcp', 'Udp', 'Icmp', 'Esp', 'Ah', or '*'."
  }
}

variable "associated_subnet_ids" {
  description = "List of subnet IDs to associate with the NSG"
  type        = list(string)
  default     = []
}

variable "associated_network_interface_ids" {
  description = "List of network interface IDs to associate with the NSG"
  type        = list(string)
  default     = []
}

variable "enable_diagnostic_setting" {
  description = "Whether to enable diagnostic settings for the NSG"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostics. If null, a new workspace will be created"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of log categories to enable in diagnostic settings"
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]

  validation {
    condition = alltrue([
      for category in var.diagnostic_log_categories : contains([
        "NetworkSecurityGroupEvent",
        "NetworkSecurityGroupRuleCounter"
      ], category)
    ])
    error_message = "Diagnostic log categories must be 'NetworkSecurityGroupEvent' or 'NetworkSecurityGroupRuleCounter'."
  }
}

variable "enable_management_lock" {
  description = "Whether to enable management lock on the NSG"
  type        = bool
  default     = false
}

variable "management_lock_level" {
  description = "Level of management lock to apply"
  type        = string
  default     = "CanNotDelete"

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.management_lock_level)
    error_message = "Management lock level must be 'CanNotDelete' or 'ReadOnly'."
  }
}

variable "management_lock_notes" {
  description = "Notes for the management lock"
  type        = string
  default     = "Managed by Terraform - do not delete"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 15
    error_message = "A maximum of 15 tags can be applied to each resource."
  }
} 