resource "databricks_notebook" "job_init" {
  language = "PYTHON" 
  source = "${path.module}/code/job_init.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/job_init"
}

resource "databricks_notebook" "taxidata_ingestion" {
  language = "PYTHON" 
  source = "${path.module}/code/taxidata-ingest.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/taxidata-ingest"
}
