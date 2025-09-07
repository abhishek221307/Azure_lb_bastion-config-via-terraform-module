
data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.rg_name
}
