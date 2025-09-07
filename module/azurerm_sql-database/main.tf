
resource "azurerm_mssql_database" "polaris-db" {
  name         = var.sql_database_name
  server_id    = data.azurerm_mssql_server.polaris-dbserver.id
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

}
