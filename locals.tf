locals {
  workspace  = local.env[terraform.workspace]
  name       = "stu-sql-ingest-${terraform.workspace}"
  short_name = "stusqlingest${terraform.workspace}"
  location   = "australiaeast"

  env = {
    dev = {
    }
    prod = {
    }
  }
}
