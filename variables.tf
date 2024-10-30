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
  description = "The URL of the workspace e.g. https://adb-43432432423423.43.azuredatabricks.net  NOTE: must not have trailing '/'"
}

variable "workspace_token" {
  type        = string
  description = "The PAT token used to access to workspace"
}
