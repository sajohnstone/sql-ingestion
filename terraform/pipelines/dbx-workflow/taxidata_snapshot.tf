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
            "referenceName" : var.pipeline_taxi_snapshot_name,
            "type" : "PipelineReference"
          },
          "waitOnCompletion" : true,
        }
      },
      {
        "name" : "Start Workflow",
        "type" : "ExecutePipeline",
        "dependsOn" : [
          {
            "activity" : "CopyDataActivity",
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
