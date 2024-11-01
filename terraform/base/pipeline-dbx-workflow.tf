resource "azurerm_data_factory_pipeline" "databricks_job_pipeline" {
  name            = "${var.name}-dbx-workflow"
  data_factory_id = azurerm_data_factory.this.id
  folder          = "Internal Pipelines"

  activities_json = jsonencode(
    [
      {
        "name" : "Execute Jobs API",
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
            "value" : "@concat(pipeline().parameters.Workspace_url,'/api/2.1/jobs/run-now')",
            "type" : "Expression"
          },
          "body" : {
            "value" : "@concat('{\"job_id\":',pipeline().parameters.JobID,'}')",
            "type" : "Expression"
          },
          "headers" : {
            "Authorization" : "@concat('Bearer ', pipeline().parameters.Workspace_token)"
          }
        }
      },
      {
        "name" : "Wait Until Job Completes",
        "type" : "Until",
        "dependsOn" : [
          {
            "activity" : "Execute Jobs API",
            "dependencyConditions" : [
              "Succeeded"
            ]
          }
        ],
        "userProperties" : [],
        "typeProperties" : {
          "expression" : {
            "value" : "@not(equals(variables('JobStatus'),'Running'))",
            "type" : "Expression"
          },
          "activities" : [
            {
              "name" : "Check Job Run API",
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
                  "value" : "@concat(pipeline().parameters.Workspace_url,'/api/2.1/jobs/runs/get?run_id=',activity('Execute Jobs API').output.run_id)",
                  "type" : "Expression"
                },
                "headers" : {
                  "Authorization" : "@concat('Bearer ', pipeline().parameters.Workspace_token)"
                }
              }
            },
            {
              "name" : "Set Job Status",
              "type" : "SetVariable",
              "dependsOn" : [
                {
                  "activity" : "Check Job Run API",
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
                "variableName" : "JobStatus",
                "value" : {
                  "value" : "@if(\nor(\nequals(activity('Check Job Run API').output.state.life_cycle_state, 'PENDING'), equals(activity('Check Job Run API').output.state.life_cycle_state, 'RUNNING')\n),\n'Running',\nactivity('Check Job Run API').output.state.result_state\n)",
                  "type" : "Expression"
                }
              }
            },
            {
              "name" : "Wait to Recheck API",
              "type" : "Wait",
              "dependsOn" : [
                {
                  "activity" : "Set Job Status",
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
    JobID           = "string"
    Workspace_url   = "string"
    Workspace_token = "string"
    WaitSeconds     = "int"
  }

  variables = {
    JobStatus = "Running"
  }
}
