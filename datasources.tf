data "http" "my_ip" {
  url = "https://ifconfig.me"
}

data "databricks_current_user" "me" {
}
