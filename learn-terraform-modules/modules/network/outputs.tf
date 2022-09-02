output "network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "web_subnet_id" {
  value = azurerm_subnet.websubnet.id
}

output "app_subnet_id" {
  value = azurerm_subnet.appsubnet.id
}

output "db_subnet_id" {
  value = azurerm_subnet.dbsubnet.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastionsubnet.id
}