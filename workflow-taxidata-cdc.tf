resource "databricks_notebook" "job_init" {
  language = "PYTHON" 
  source = "${path.module}//notebooks/job_init.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/job_init"
}

resource "databricks_notebook" "taxidata_cdc" {
  language = "PYTHON" 
  source = "${path.module}/notebooks/taxidata-cdc.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/taxidata-cdc"
}

resource "databricks_job" "this" {
  name = "${local.name}-taxi-cdc"

  task {
    task_key = "run_ingestion"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_cdc.path
      base_parameters = {
        table_name = "taxi_data_cdc",
        schema_name = "bronze" 
      }
    }
  }
}
