variable "name" {
  type        = string
  description = "The prefix used for naming resources"
}

variable "short_name" {
  type        = string
  description = "An abbreviated prefix for naming resources, used where character limits apply"
}

variable "sql_server_password" {
  type        = string
  description = "The password for the SQL Server instance"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where resources will be deployed"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be created"
}

variable "workspace_token" {
  type        = string
  description = "The PAT token used to access to workspace"
}
