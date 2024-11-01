resource "databricks_notebook" "taxidata_dlt" {
  language = "PYTHON"
  source   = "${path.module}/code/taxidata-dlt.py"
  path     = "${data.databricks_current_user.me.home}/notebooks/jobs/taxidata-dlt"
}

resource "databricks_pipeline" "taxi_data_pipeline" {
  name    = "Taxi Data DLT Pipeline"
  catalog = "stu_sandbox"
  target  = "bronze"

  library {
    notebook {
      path = databricks_notebook.taxidata_dlt.id
    }
  }

  configuration = {
    "schema_name" = "bronze"
    "table_name"  = "taxi_data_cdc"
  }

  continuous = false
  development  = true
  serverless = true

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
