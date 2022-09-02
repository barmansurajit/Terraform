resource "azurerm_virtual_network" "vnet" {
  name = var.name
  location = var.location
  address_space = var.vnet_address_space
  resource_group_name = var.resource_group
  tags = var.tags
}

resource "azurerm_subnet" "websubnet" {
  name = var.web_subnet_name
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.web_subnet_address
}

resource "azurerm_subnet" "appsubnet" {
  name = var.app_subnet_name
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.app_subnet_address
}

resource "azurerm_subnet" "dbsubnet" {
  name = var.db_subnet_name
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.db_subnet_address
}

resource "azurerm_subnet" "bastionsubnet" {
  name = var.bastion_subnet_name
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.bastion_subnet_address
}