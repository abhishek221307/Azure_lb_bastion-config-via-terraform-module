resource "azurerm_lb" "lb" {
  name                = "Netflix-LoadBalancer"
  location            = var.location
  resource_group_name = var.rg_name

  frontend_ip_configuration {
    name                 = "Netflix-PublicIPAddress"
    public_ip_address_id = data.azurerm_public_ip.pip.id
  }
}



resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}


resource "azurerm_lb_probe" "hc-probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "netflix-probe"
  port            = 80
}

# IP and Port based rule
resource "azurerm_lb_rule" "netflix-lbrule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Netflix-PublicIPAddress"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend.id]
  probe_id = azurerm_lb_probe.hc-probe.id
}

