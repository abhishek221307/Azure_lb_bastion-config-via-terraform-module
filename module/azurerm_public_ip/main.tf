resource "azurerm_public_ip" "polaris-pip" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}