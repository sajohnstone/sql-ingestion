resource "databricks_notebook" "taxidata_dlt" {
  language = "PYTHON"
  source   = "${path.module}/code/taxidata-dlt.py"
  path     = "${data.databricks_current_user.me.home}/notebooks/jobs/taxidata-dlt"
}

resource "databricks_pipeline" "taxidata_cdc" {
  name    = "Taxi Data DLT Pipeline"
  catalog = "stu_sandbox"
  target  = "bronze"

  library {
    notebook {
      path = databricks_notebook.taxidata_dlt.id
    }
  }

  configuration = {
    "table_name"      = "taxi_data_cdc"
    "container_name"  = "data"
    "storage_account" = "stusqlingestdevstore"
  }

  continuous  = false
  development = true
  serverless  = true

  notification {
    email_recipients = ["stu.johnstone@mantelgroup.com.au"]
    alerts = [
      "on-update-failure",
      "on-update-fatal-failure",
      "on-update-success",
      "on-flow-failure"
    ]
  }
}

resource "azurerm_data_factory_pipeline" "taxi_cdc" {
  name            = "${var.name}-taxi-dlt-cdc"
  data_factory_id = var.data_factory_id
  folder          = "CDC Pipelines"

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
            "tableName" : "dbo_TaxiData_CT",
            "outputPath" : "taxi_data_cdc"
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
            "referenceName" : var.pipeline_dbx_dlt_name,
            "type" : "PipelineReference"
          },
          "waitOnCompletion" : true,
          "parameters" : {
            "Workspace_url" : var.workspace_url,
            "PipelineID" : databricks_pipeline.taxidata_cdc.id,
            "WaitSeconds" : "60"
            "Workspace_token" : var.workspace_token
          }
        }
      }
    ]
  )
}
