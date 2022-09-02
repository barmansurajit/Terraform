department              = "retail"
environment             = "dev"
resource_group_location = "centralus"
resource_group_name     = "tier-design"

vnet_address_space = ["10.1.0.0/16"]
vnet_name          = "vnet"

web_subnet_name    = "web-subnet"
web_subnet_address = ["10.1.1.0/24"]

app_subnet_name    = "app-subnet"
app_subnet_address = ["10.1.11.0/24"]

db_subnet_name    = "db-subnet"
db_subnet_address = ["10.1.21.0/24"]

bastion_subnet_name    = "bastion-subnet"
bastion_subnet_address = ["10.1.100.0/24"]