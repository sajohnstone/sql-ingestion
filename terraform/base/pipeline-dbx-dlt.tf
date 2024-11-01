resource "azurerm_data_factory_pipeline" "databricks_dlt_pipeline" {
  name            = "${var.name}-dlt-pipeline"
  data_factory_id = azurerm_data_factory.this.id
  folder          = "Internal Pipelines"

  activities_json = jsonencode(
    [
      {
        "name" : "Start DLT Pipeline",
        "type" : "WebActivity",
        "dependsOn" : [],
        "policy" : {
          "timeout" : "0.12:00:00",
          "retry" : 0,
          "retryIntervalInSeconds" : 30,
          "secureOutput" : false,
          "secureInput" : false
        },
        "userProperties" : [],
        "typeProperties" : {
          "method" : "POST",
          "url" : {
            "value" : "@concat(pipeline().parameters.Workspace_url,'/api/2.0/pipelines/',pipeline().parameters.PipelineID,'/start')",
            "type" : "Expression"
          },
          "headers" : {
            "Authorization" : "@concat('Bearer ', pipeline().parameters.Workspace_token)"
          }
        }
      },
      {
        "name" : "Wait Until DLT Pipeline Completes",
        "type" : "Until",
        "dependsOn" : [
          {
            "activity" : "Start DLT Pipeline",
            "dependencyConditions" : [
              "Succeeded"
            ]
          }
        ],
        "userProperties" : [],
        "typeProperties" : {
          "expression" : {
            "value" : "@not(equals(variables('PipelineStatus'),'RUNNING'))",
            "type" : "Expression"
          },
          "activities" : [
            {
              "name" : "Check DLT Pipeline Status",
              "type" : "WebActivity",
              "dependsOn" : [],
              "policy" : {
                "timeout" : "0.12:00:00",
                "retry" : 0,
                "retryIntervalInSeconds" : 30,
                "secureOutput" : false,
                "secureInput" : false
              },
              "userProperties" : [],
              "typeProperties" : {
                "method" : "GET",
                "url" : {
                  "value" : "@concat(pipeline().parameters.Workspace_url,'/api/2.0/pipelines/',pipeline().parameters.PipelineID,'/status')",
                  "type" : "Expression"
                },
                "headers" : {
                  "Authorization" : "@concat('Bearer ', pipeline().parameters.Workspace_token)"
                }
              }
            },
            {
              "name" : "Set Pipeline Status",
              "type" : "SetVariable",
              "dependsOn" : [
                {
                  "activity" : "Check DLT Pipeline Status",
                  "dependencyConditions" : [
                    "Succeeded"
                  ]
                }
              ],
              "policy" : {
                "secureOutput" : false,
                "secureInput" : false
              },
              "userProperties" : [],
              "typeProperties" : {
                "variableName" : "PipelineStatus",
                "value" : {
                  "value" : "@if(or(equals(activity('Check DLT Pipeline Status').output.update.state, 'PENDING'), equals(activity('Check DLT Pipeline Status').output.update.state, 'RUNNING')), 'RUNNING', activity('Check DLT Pipeline Status').output.update.state)",
                  "type" : "Expression"
                }
              }
            },
            {
              "name" : "Wait to Recheck Pipeline Status",
              "type" : "Wait",
              "dependsOn" : [
                {
                  "activity" : "Set Pipeline Status",
                  "dependencyConditions" : [
                    "Succeeded"
                  ]
                }
              ],
              "userProperties" : [],
              "typeProperties" : {
                "waitTimeInSeconds" : {
                  "value" : "@pipeline().parameters.WaitSeconds",
                  "type" : "Expression"
                }
              }
            }
          ],
          "timeout" : "7.00:00:00"
        }
      }
    ]
  )

  parameters = {
    PipelineID     = "string"
    Workspace_url  = "string"
    Workspace_token  = "string"
    WaitSeconds    = "int"
  }

  variables = {
    PipelineStatus = "RUNNING"
  }
}