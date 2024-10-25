resource "databricks_notebook" "taxidata_sql" {
  language = "PYTHON" 
  source = "${path.module}/notebooks/taxtdata-sql-ingest.py"
  path   = "${data.databricks_current_user.me.home}/notebooks/jobs/taxtdata-sql-ingest"
}

resource "databricks_job" "taxidata_sql_ingestion" {
  name = "${local.name}-taxi-sql-ingestion"

  task {
    task_key = "cdc_sql_ingestion"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_sql.path
      base_parameters = {
        jdbc_hostname = azurerm_mssql_server.this.fully_qualified_domain_name
        jdbc_port = "1433"
        jdbc_database = azurerm_mssql_database.this.name
        jdbc_username = azurerm_mssql_server.this.administrator_login
        jdbc_password = var.sql_server_password
        table_name = "dbo_TaxiData_CT"
        delta_table_name = "stu_sandbox.bronze.sql_cdc_taxi_data"
      }
    }
  }
  task {
    task_key = "snapshot_sql_ingestion"
    notebook_task {
      notebook_path = databricks_notebook.taxidata_sql.path
      base_parameters = {
        jdbc_hostname = azurerm_mssql_server.this.fully_qualified_domain_name
        jdbc_port = "1433"
        jdbc_database = azurerm_mssql_database.this.name
        jdbc_username = azurerm_mssql_server.this.administrator_login
        jdbc_password = var.sql_server_password
        table_name = "TaxiData"
        delta_table_name = "stu_sandbox.bronze.sql_taxi_data"
      }
    }
  }
}
