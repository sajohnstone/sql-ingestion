resource "databricks_job" "taxidata_sql_snapshot" {
  name = "${var.name}-taxi-sql-snapshot"

  task {
    task_key = "start_sql_ingestion"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_sql.path
      base_parameters = {
        jdbc_hostname = var.sql_server_fqdn
        jdbc_port = var.sql_server_port
        jdbc_database = var.sql_server_database
        jdbc_username = var.sql_server_username
        jdbc_password = var.sql_server_password
        table_name = "TaxiData"
        delta_table_name = "stu_sandbox.bronze.sql_taxi_data"
      }
    }
  }
}

resource "azurerm_data_factory_pipeline" "taxi_snapshot" {
  name            = "${var.name}-taxi-sql-snapshot"
  data_factory_id = var.data_factory_id

  activities_json = jsonencode(
    [
      {
        "name" : "Start Workflow",
        "type" : "ExecutePipeline",
        "policy" : {
          "secureInput" : false
        },
        "userProperties" : [],
        "typeProperties" : {
          "pipeline" : {
            "referenceName" : var.pipeline_dbx_workflow_name,
            "type" : "PipelineReference"
          },
          "waitOnCompletion" : true,
          "parameters" : {
            "Workspace_url" : var.workspace_url,
            "JobID" : databricks_job.taxidata_sql_snapshot.id,
            "WaitSeconds" : "60"
          }
        }
      }
    ]
  )
}
