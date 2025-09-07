data "azurerm_network_interface" "nic" {
  name                = var.nic_name
  resource_group_name = var.rg_name
}

data "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = var.backend_pool_name
  loadbalancer_id    = data.azurerm_lb.lb.id
}

data "azurerm_lb" "lb" {
  name                = var.lb_name
  resource_group_name = var.rg_name
  
}