resource "databricks_notebook" "job_init" {
  language = "PYTHON" 
  source = "${path.module}//notebooks/job_init.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/job_init"
}

resource "databricks_notebook" "taxidata_ingestion" {
  language = "PYTHON" 
  source = "${path.module}/notebooks/taxidata-ingest.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/taxidata-ingest"
}

resource "databricks_job" "taxidata_ingestion_cdc" {
  name = "${local.name}-taxi-ingestion-cdc"

  task {
    task_key = "cdc_run_ingestion-cdc"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_ingestion.path
      base_parameters = {
        table_name = "taxi_data_cdc",
        schema_name = "bronze" 
      }
    }
  }
}

resource "databricks_job" "taxidata_ingestion" {
  name = "${local.name}-taxi-ingestion"

  task {
    task_key = "snapshot_run_ingestion"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_ingestion.path
      base_parameters = {
        table_name = "taxi_data_snapshot",
        schema_name = "bronze" 
      }
    }
  }
}
