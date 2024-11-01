resource "azurerm_data_factory_pipeline" "taxi_snapshot" {
  name            = "${var.name}-taxi-snapshot"
  data_factory_id = var.data_factory_id

  activities_json = jsonencode(
    [
      {
        "name" : "CopyData",
        "type" : "ExecutePipeline",
        "policy" : {
          "secureInput" : false
        },
        "userProperties" : [],
        "typeProperties" : {
          "pipeline" : {
            "referenceName" : var.pipeline_sql_to_adls_pipeline,
            "type" : "PipelineReference"
          },
          "waitOnCompletion" : true,
          "parameters" : {
            "container" : "data"
            "tableName" : "TaxiData",
            "outputPath" : "taxi_data_snapshot"
          }
        }
      },
      {
        "name" : "Start Workflow",
        "type" : "ExecutePipeline",
        "dependsOn" : [
          {
            "activity" : "CopyData",
            "dependencyConditions" : [
              "Succeeded"
            ]
          }
        ],
        "policy" : {
          "secureInput" : false
        },
        "userProperties" : [],
        "typeProperties" : {
          "pipeline" : {
            "referenceName" : var.pipeline_dbx_workflow_name
            "type" : "PipelineReference"
          },
          "waitOnCompletion" : true,
          "parameters" : {
            "Workspace_url" : var.workspace_url,
            "JobID" : databricks_job.taxidata_snapshot.id,
            "WaitSeconds" : "60"
            "Workspace_token" : var.workspace_token
          }
        }
      }
    ]
  )
}

resource "databricks_job" "taxidata_snapshot" {
  name = "${var.name}-taxi-snapshot"

  task {
    task_key = "start_ingestion"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_ingestion.path
      base_parameters = {
        table_name = "taxi_data_snapshot",
        schema_name = "bronze" 
      }
    }
  }
}
