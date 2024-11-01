locals {
  workspace  = local.env[terraform.workspace]
  name       = "stu-sql-ingest-${terraform.workspace}"
  short_name = "stusqlingest${terraform.workspace}"
  location   = "australiaeast"
  workspace_id = regex("\\badb-(\\d+)\\b", var.workspace_url)[0]

  env = {
    dev = {
    }
    prod = {
    }
  }
}
