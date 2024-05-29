terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.105.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "azurerm" {
    features {}
}

provider "local" {}

provider "tls" {}

resource "azurerm_resource_group" "rg" {
  name     = "tpe-redes"
  location = "eastus"
}
