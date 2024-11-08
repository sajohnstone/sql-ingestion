module "sql-jdbc" {
  source                     = "./pipelines/sql-jdbc"
  name                       = local.name
  data_factory_id            = module.base.data_factory_id
  workspace_url              = var.workspace_url
  pipeline_dbx_workflow_name = module.base.pipeline_dbx_workflow_name
  sql_server_database        = module.base.sql_server_database
  sql_server_fqdn            = module.base.sql_server_fqdn
  sql_server_username        = module.base.sql_server_username
  sql_server_password        = var.sql_server_password
  depends_on                 = [module.base]
}

module "dxt-workflow" {
  source                        = "./pipelines/dbx-workflow"
  name                          = local.name
  data_factory_id               = module.base.data_factory_id
  workspace_url                 = var.workspace_url
  pipeline_sql_to_adls_pipeline = module.base.pipeline_sql_to_adls_pipeline
  pipeline_dbx_workflow_name    = module.base.pipeline_dbx_workflow_name
  workspace_token               = var.workspace_token
  depends_on                    = [module.base]
}

module "dbx-dlt" {
  source                        = "./pipelines/dbx-dlt"
  name                          = local.name
  data_factory_id               = module.base.data_factory_id
  workspace_url                 = var.workspace_url
  pipeline_sql_to_adls_pipeline = module.base.pipeline_sql_to_adls_pipeline
  pipeline_dbx_dlt_name         = module.base.pipeline_dbx_dlt_name
  workspace_token               = var.workspace_token
  depends_on                    = [module.base]
}
