resource "azurerm_network_security_group" "web_subnet_nsg" {
  name                = "${var.web_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg_association" {
  depends_on = [
    azurerm_network_security_rule.web_nsg_rule_inbound
  ]
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web_subnet_nsg.id
}

locals {
  web_inbound_ports_map = {
    "100" : "80"
    "110" : "443"
    "120" : "22"
  }
}

resource "azurerm_network_security_rule" "web_nsg_rule_inbound" {
  for_each                    = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

####

resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "${var.app_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_association" {
  depends_on = [
    azurerm_network_security_rule.app_nsg_rule_inbound
  ]
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
}

locals {
  app_inbound_ports_map = {
    "100" : "80"
    "110" : "443"
    "120" : "8080"
    "130" : "22"
  }
}

resource "azurerm_network_security_rule" "app_nsg_rule_inbound" {
  for_each                    = local.app_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
}
###

resource "azurerm_network_security_group" "db_subnet_nsg" {
  name                = "${var.db_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_association" {
  depends_on = [
    azurerm_network_security_rule.db_nsg_rule_inbound
  ]
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db_subnet_nsg.id
}

locals {
  db_inbound_ports_map = {
    "100" : "3306"
    "110" : "1443"
    "120" : "5432"
  }
}

resource "azurerm_network_security_rule" "db_nsg_rule_inbound" {
  for_each                    = local.db_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.db_subnet_nsg.name
}
###
resource "azurerm_network_security_group" "bastion_subnet_nsg" {
  name                = "${var.bastion_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_association" {
  depends_on = [
    azurerm_network_security_rule.bastion_nsg_rule_inbound
  ]
  subnet_id                 = var.bastion_subnet_id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_nsg.id
}

locals {
  bastion_inbound_ports_map = {
    "100" : "22"
    "110" : "3389"
  }
}

resource "azurerm_network_security_rule" "bastion_nsg_rule_inbound" {
  for_each                    = local.bastion_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.bastion_subnet_nsg.name
}