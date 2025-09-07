resource "azurerm_virtual_network" "polaris-vnet" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.rg_name
}