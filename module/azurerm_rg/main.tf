resource "azurerm_resource_group" "polarisrg" {
  name     = var.rg_name
  location = var.location
}
