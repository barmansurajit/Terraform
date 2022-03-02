# resource "azurerm_public_ip" "web_linuxvm_publicip" {
#   name                = "${local.resource_name_prefix}-web-linuxvm-publicip"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
#   # Basic
#   sku = "Standard"
#   # If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.
#   domain_name_label = "app1-vm-${random_string.random.id}"
#   tags              = local.common_tags
# }