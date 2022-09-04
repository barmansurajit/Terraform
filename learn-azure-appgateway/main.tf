terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resouce_location
  tags = {
    "environment" = "stage"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    "environment" = "stage"
  }
}

# Web Application Windows VM Subnet networking resources
resource "azurerm_subnet" "websubnet" {
  name                 = var.web_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "webnsg" {
  name                = var.web_nsg
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "websubnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.web_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.webnsg.id
}

locals {
  web_inbound_ports_map = {
    "100" : "80",    # For accessing the IIS application: HTTP
    "1000" : "3389", # For RDP
    "1100" : "51820"
  }
}

resource "azurerm_network_security_rule" "web_nsg_rule_inbound" {
  for_each                    = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.webnsg.name
}

# Application Gateway Subnet networking resources
resource "azurerm_subnet" "agsubnet" {
  name                 = var.ag_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "agnsg" {
  name                = var.ag_nsg
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "agsubnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.ag_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.agsubnet.id
  network_security_group_id = azurerm_network_security_group.agnsg.id
}

locals {
  ag_inbound_ports_map = {
    "100" : "80",         # For accessing the IIS application: HTTP
    "110" : "443",        # For accessing the IIS application: HTTPS
    "130" : "65200-65535" # TCP ports 65200-65535 for application gateway v2 SKU. This port range is required for Azure infrastructure communication.: NSG section at https://docs.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure
  }
}

resource "azurerm_network_security_rule" "ag_nsg_rule_inbound" {
  for_each                    = local.ag_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.agnsg.name
}

# Public IP for the application gateway
resource "azurerm_public_ip" "ag_publicip" {
  name                = var.ag_public_ip
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard" # SKU required for application gateway setup
  tags = {
    "environment" = "stage"
  }
}

# Application Gateway related configuration
resource "azurerm_application_gateway" "ag_iis" {
  name                = var.app_gateway
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2 # Capacity required if VMSS (VM Scale Set) not defined
  }

  gateway_ip_configuration {
    name      = var.ag_ip_config
    subnet_id = azurerm_subnet.agsubnet.id
  }

  frontend_port {
    name = var.ag_frontend_port
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.ag_frontend_ip_config
    public_ip_address_id = azurerm_public_ip.ag_publicip.id
  }

  backend_address_pool {
    name = var.ag_backend_address_pool
  }

  backend_http_settings {
    name                  = var.ag_backend_http_setting
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.ag_http_listener
    frontend_ip_configuration_name = var.ag_frontend_ip_config
    frontend_port_name             = var.ag_frontend_port
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.ag_request_routing_rule
    rule_type                  = "Basic"
    http_listener_name         = var.ag_http_listener
    backend_address_pool_name  = var.ag_backend_address_pool
    backend_http_settings_name = var.ag_backend_http_setting
  }
}

# NIC configuration for attaching to the Windows VMs
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vm_name)
  name                = "${var.network_interface_name}-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "nic-ipconfig-${each.key}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.websubnet.id
  }
}

# Attach/Associate NICs and application gateway
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic_app_gtwy_associate" {
  for_each                = toset(var.vm_name)
  network_interface_id    = azurerm_network_interface.nic[each.key].id
  ip_configuration_name   = "nic-ipconfig-${each.key}"
  backend_address_pool_id = azurerm_application_gateway.ag_iis.backend_address_pool[0].id
}

# Windows VM configuration resources
resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each              = toset(var.vm_name)
  name                  = each.value
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1ms"
  admin_username        = "adminuser"
  admin_password        = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Install and setup IIS Server, print the server name in the default HTML which gets setup through powershell
resource "azurerm_virtual_machine_extension" "install-iis" {
  for_each             = toset(var.vm_name)
  name                 = "${var.iis_server}-${each.key}"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
    SETTINGS
}

# Shutdown the Windows VMs at 2100 (9PM) CST
resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  for_each           = toset(var.vm_name)
  virtual_machine_id = azurerm_windows_virtual_machine.windows_vm[each.key].id
  location           = azurerm_windows_virtual_machine.windows_vm[each.key].location
  enabled            = true

  daily_recurrence_time = "2100"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}