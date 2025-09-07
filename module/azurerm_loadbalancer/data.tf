data "azurerm_public_ip" "pip" {
  name                = var.public_ip
  resource_group_name = var.rg_name
}