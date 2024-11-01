resource "databricks_notebook" "taxidata_sql" {
  language = "PYTHON" 
  source = "${path.module}/code/taxtdata-sql-ingest.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/taxtdata-sql-ingest"
}
