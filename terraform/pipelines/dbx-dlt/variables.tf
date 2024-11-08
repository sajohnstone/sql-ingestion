variable "name" {
  type        = string
  description = "The prefix used for naming resources"
}

variable "data_factory_id" {
  type        = string
  description = "The id of the ADF instance"
}

variable "workspace_url" {
  type        = string
  description = "The URL of the workspace e.g. https://adb-43432432423423.43.azuredatabricks.net  NOTE: must not have trailing '/'"
}

variable "pipeline_sql_to_adls_pipeline" {
  type        = string
  description = "The name of the SQL to ADLS pipeline"
}

variable "pipeline_dbx_dlt_name" {
  type        = string
  description = "The name of the start Databricks DLT pipeline"
}

variable "workspace_token" {
  type        = string
  description = "The PAT token used to access to workspace"
}
