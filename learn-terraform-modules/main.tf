terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
  }

  required_version = ">=1.1.0"
}

provider "azurerm" {
  features {}
}

locals {
  owner                = var.department
  environment          = var.environment
  resource_name_prefix = "${var.department}-${var.environment}"
  tags = {
    owner       = local.owner
    environment = local.environment
  }
}

module "resourcegroup" {
  source   = "./modules/resourcegroup"
  name     = "${local.resource_name_prefix}-${var.resource_group_name}"
  location = var.resource_group_location
  tags     = local.tags
}

module "network" {
  source                 = "./modules/network"
  name                   = "${local.resource_name_prefix}-${var.vnet_name}"
  vnet_address_space     = var.vnet_address_space
  location               = module.resourcegroup.location_id
  resource_group         = module.resourcegroup.resource_group_name
  web_subnet_name        = "${local.resource_name_prefix}-${var.web_subnet_name}"
  web_subnet_address     = var.web_subnet_address
  app_subnet_name        = "${local.resource_name_prefix}-${var.app_subnet_name}"
  app_subnet_address     = var.app_subnet_address
  db_subnet_name         = "${local.resource_name_prefix}-${var.db_subnet_name}"
  db_subnet_address      = var.db_subnet_address
  bastion_subnet_name    = "${local.resource_name_prefix}-${var.bastion_subnet_name}"
  bastion_subnet_address = var.bastion_subnet_address
  tags                   = local.tags
}

module "securitygroup" {
  source              = "./modules/securitygroup"
  location            = module.resourcegroup.location_id
  resource_group      = module.resourcegroup.resource_group_name
  web_subnet_name     = "${local.resource_name_prefix}-${var.web_subnet_name}"
  web_subnet_id       = module.network.web_subnet_id
  app_subnet_name     = "${local.resource_name_prefix}-${var.app_subnet_name}"
  app_subnet_id       = module.network.app_subnet_id
  db_subnet_name      = "${local.resource_name_prefix}-${var.db_subnet_name}"
  db_subnet_id        = module.network.db_subnet_id
  bastion_subnet_name = "${local.resource_name_prefix}-${var.bastion_subnet_name}"
  bastion_subnet_id   = module.network.bastion_subnet_id
}