module "resource_group_name" {
  source = "../module/azurerm_rg"

  rg_name  = "polaris_rgroup"
  location = "North Europe"
}

module "vnet" {
  depends_on = [module.resource_group_name]
  source     = "../module/azurerm_vnet"

  virtual_network_name = "polaris_vnet"
  address_space        = ["192.168.0.0/16"]
  location             = "North Europe"
  rg_name              = "polaris_rgroup"
}

variable "subnet_config" {
  type = map(any)
  default = {
    "frontend" = {
      name             = "polaris_subnet_frontend"
      address_prefixes = ["192.168.1.0/24"]
    }
    "backend" = {
      name             = "polaris_subnet_backend"
      address_prefixes = ["192.168.2.0/24"]
    }
    "bastion" = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["192.168.3.0/26"]
    }
  }
}
module "subnet" {
  for_each             = var.subnet_config
  depends_on           = [module.vnet]
  source               = "../module/azurerm_subnet"
  name                 = each.value.name
  rg_name              = "polaris_rgroup"
  virtual_network_name = "polaris_vnet"
  address_prefixes     = each.value.address_prefixes
}

module "public_ip" {
  source     = "../module/azurerm_public_ip"
  depends_on = [module.resource_group_name]
  name       = "bastionpip"
  location   = "North Europe"
  rg_name    = "polaris_rgroup"
}


module "bastion" {
  depends_on           = [module.subnet, module.public_ip]
  source               = "../module/azurerm_bastion"
  name                 = "polaris-bastion"
  location             = "North Europe"
  rg_name              = "polaris_rgroup"
  virtual_network_name = "polaris_vnet"
  subnet               = "AzureBastionSubnet"
  public_ip            = "bastionpip"

}


variable "nic_config" {
  type = map(any)
  default = {
    "frontend1" = {
      name     = "nic-frontend1"
      subnet   = "polaris_subnet_frontend"
      nsg_name = "frontend-nsg"
    }
    "frontend2" = {
      name     = "nic-frontend2"
      subnet   = "polaris_subnet_frontend"
      nsg_name = "frontend-nsg"
    }

    "backend" = {
      name     = "nic-backend"
      subnet   = "polaris_subnet_backend"
      nsg_name = "backend-nsg"
    }
  }
}


module "nic" {
  for_each             = var.nic_config
  source               = "../module/azurerm_nic"
  depends_on           = [module.subnet]
  name                 = each.value.name
  location             = "North Europe"
  rg_name              = "polaris_rgroup"
  nsg_name             = each.value.nsg_name
  subnet               = each.value.subnet
  virtual_network_name = "polaris_vnet"

}

variable "vm_config" {
  type = map(any)
  default = {
    "frontend1" = {
      nic_name       = "nic-frontend1"
      admin_username = "frontendAdmin"
      admin_password = "frontend#1Pass"
      publisher      = "Canonical"
      offer          = "0001-com-ubuntu-server-jammy"
      sku            = "22_04-lts"
      nsg_name       = "frontend-nsg"
      custom_data    = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y nginx
        sudo systemctl enable nginx
        sudo systemctl start nginx
      EOF
    }

    "frontend2" = {
      nic_name       = "nic-frontend2"
      admin_username = "frontendAdmin"
      admin_password = "frontend#1Pass"
      publisher      = "Canonical"
      offer          = "0001-com-ubuntu-server-jammy"
      sku            = "22_04-lts"
      custom_data    = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y nginx
        sudo systemctl enable nginx
        sudo systemctl start nginx
      EOF
    }


    "backend" = {
      nic_name       = "nic-backend"
      admin_username = "backendAdmin"
      admin_password = "backend#1Pass"
      publisher      = "Canonical"
      offer          = "0001-com-ubuntu-server-focal"
      sku            = "20_04-lts"
      custom_data    = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install -y python3 python3-pip
      EOF

    }
  }
}
module "virtual_machine" {
  depends_on             = [module.subnet, module.nic]
  for_each               = var.vm_config
  source                 = "../module/azurerm_vm"
  name                   = "polaris-${each.key}vm"
  rg_name                = "polaris_rgroup"
  network_interface_name = each.value.nic_name
  #key_vault_name         = "polaris-key"
  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  location       = "North Europe"
  publisher      = each.value.publisher
  offer          = each.value.offer
  sku            = each.value.sku
  custom_data    = base64encode(each.value.custom_data)
}

module "public_ip_loadbalancer" {
  source     = "../module/azurerm_public_ip"
  depends_on = [module.resource_group_name]
  name       = "netflix-pip"
  location   = "North Europe"
  rg_name    = "polaris_rgroup"
}

module "loadbalancer" {
  depends_on = [module.virtual_machine, module.public_ip_loadbalancer]
  source     = "../module/azurerm_loadbalancer"
  location   = "North Europe"
  rg_name    = "polaris_rgroup"
  public_ip  = "netflix-pip"

}

module "lb_nic_association" {
  for_each = {
    for k, v in var.nic_config : k => v
    if length(regexall("frontend", k)) > 0
  }
  depends_on            = [module.loadbalancer, module.virtual_machine]
  source                = "../module/azurerm_nic_lb_association"
  rg_name               = "polaris_rgroup"
  nic_name              = each.value.name
  lb_name               = "Netflix-LoadBalancer"
  backend_pool_name     = "BackEndAddressPool"
  ip_configuration_name = "internal"

}


module "server" {
  depends_on      = [module.resource_group_name]
  source          = "../module/azurerm_sql-server"
  sql_server_name = "polaris-server"
  rg_name         = "polaris_rgroup"
  location        = "North Europe"
  #key_vault_name  = "polaris-key"
  admin_username = "dbAdmin"
  admin_password = "db#1pasS"
}

module "database" {
  depends_on        = [module.server]
  source            = "../module/azurerm_sql-database"
  sql_database_name = "polaris-database"
  sql_server_name   = "polaris-server"
  rg_name           = "polaris_rgroup"
}

