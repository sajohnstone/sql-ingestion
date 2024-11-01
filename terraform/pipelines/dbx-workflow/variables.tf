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

variable "pipeline_taxi_cdc_name" {
  type = string
}

variable "pipeline_taxi_snapshot_name" {
  type = string
}

variable "pipeline_dbx_workflow_name" {
  type = string
}

