terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.0"
    }
  }
  # backend "azurerm" {
  #     resource_group_name   = "bhmrg"   
  #     storage_account_name  = "bhmstorage234"
  #     container_name        = "bhmtf"
  #     key                   = "bastiontf.tfstate"
  #   }
}

provider "azurerm" {
  features {}
  subscription_id = "18f8e7c5-a3db-4324-b49d-7ef07eace03f"
}
