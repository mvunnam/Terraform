terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "f50ba649-82bf-4ed5-ad01-9cddc408fd1a"
  client_id       = "1588b990-5b90-428d-9e2e-4c7456e91f2a"
  client_secret   = "tiW8Q~RXSeyThIQJewDPB~gUahLDtKFaaDyH0bdO"
  tenant_id       = "3fdc4063-070a-41f4-a202-2e330d07de5c"
  
}    

locals {
  rgname = "RG1"
  rglocation = "East US"
  vnet_name = "ama-vnet1"
  snet_name = "Subnet1"
  rt_table = "rt_table_name"
}

# Create a resource group
resource "azurerm_resource_group" "rg1" {
  name     = "${var.rg_name}"
  location = "${var.rg_location}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "VNET1" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.196.0.0/16"]
}

resource "azurerm_subnet" "subenet1" {
  name = local.snet_name
  resource_group_name = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes = ["10.196.1.0/24"]
}

resource "azurerm_network_security_group" "sg1" {
  name = "securitygroup"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_virtual_network.VNET1.location

  security_rule {
    name = "SGroup"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "sga1" {
  subnet_id = azurerm_subnet.subenet1.id
  network_security_group_id = azurerm_network_security_group.sg1.id
  
}

resource "azurerm_route_table" "rttable" {
  name = local.rt_table
  location = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  route {
    name = "rtname"
    address_prefix = "10.196.0.0/24"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"

  }  
}
resource "azurerm_subnet_route_table_association" "rta_table" {
  subnet_id = azurerm_subnet.subenet1.id
  route_table_id = azurerm_route_table.rttable.id
  
}
