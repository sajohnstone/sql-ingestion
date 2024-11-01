variable "name" {
  type        = string
  description = "The prefix used for naming resources across the deployment"
}

variable "sql_server_fqdn" {
  type        = string
  description = "The fully qualified domain name (FQDN) of the SQL Server instance"
}

variable "sql_server_database" {
  type        = string
  description = "The name of the database hosted on the SQL Server instance"
}

variable "sql_server_username" {
  type        = string
  description = "The username used to authenticate with the SQL Server instance"
}

variable "sql_server_password" {
  type        = string
  description = "The password used to authenticate with the SQL Server instance"
}

variable "sql_server_port" {
  type        = string
  description = "The port on which the SQL Server instance is accessible, defaulting to 1433"
  default     = "1433"
}

variable "data_factory_id" {
  type        = string
  description = "The resource ID of the Azure Data Factory (ADF) instance"
}

variable "workspace_url" {
  type        = string
  description = "The URL of the Databricks workspace (e.g., https://adb-43432432423423.43.azuredatabricks.net), without a trailing '/'"
}

variable "pipeline_dbx_workflow_name" {
  type        = string
  description = "The name of the Databricks workflow pipeline"
}