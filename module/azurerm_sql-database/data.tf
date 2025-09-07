data "azurerm_mssql_server" "polaris-dbserver" {
  name                = var.sql_server_name
  resource_group_name = var.rg_name
}