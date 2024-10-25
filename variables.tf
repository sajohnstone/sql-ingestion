variable "azure_subscription_id" {
  type        = string
  description = "The ID of the Azure subscription"
}

variable "sql_server_password" {
  type        = string
  description = "The password of the SQL server"
}

variable "workspace_url" {
  type        = string
  description = "The ID of the workspace"
}

variable "workspace_token" {
  type        = string
  description = "The PAT token used to access to workspace"
}
