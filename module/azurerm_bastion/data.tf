
data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.rg_name
}

data "azurerm_public_ip" "pip" {
  name                = var.public_ip
  resource_group_name = var.rg_name
}
